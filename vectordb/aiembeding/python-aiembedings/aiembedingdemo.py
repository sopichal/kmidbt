#!/usr/bin/env python3
"""
AI Embedding Demo - Cross-platform Python CLI

A command-line utility for working with OpenAI text embeddings and PostgreSQL pgvector.
Supports get-embeddings, store-embeddings, and query-similar commands.
"""

import argparse
import json
import os
import sys
from datetime import datetime
from pathlib import Path
from typing import Optional, Tuple, Dict, Any, List

# Third-party imports
try:
    import psycopg2
    from psycopg2.extras import Json
    from dotenv import load_dotenv
    from openai import OpenAI
    from pypdf import PdfReader
except ImportError as e:
    print(f"Error: Missing required package. Please install dependencies:")
    print("  uv pip install -r requirements.txt")
    print(f"\nMissing package: {e.name}")
    sys.exit(1)

# Constants
MODEL = "text-embedding-3-small"
EMBEDDING_DIMENSIONS = 1536
MAX_TOKENS = 8192  # OpenAI model token limit
CHUNK_SIZE = 5000  # Conservative chunk size in tokens (leave room for safety)
CHARS_PER_TOKEN = 2  # Conservative approximation for math/special chars (1 token ≈ 2-4 chars)
DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "user": "vectoruser",
    "password": "vectorpass",
    "database": "vectordb"
}
RESULT_LIMIT = 5


def load_env() -> None:
    """Load environment variables from .env file."""
    env_path = Path(__file__).parent / ".env"
    if not env_path.exists():
        # Try parent directory
        env_path = Path(__file__).parent.parent / ".env"

    if env_path.exists():
        load_dotenv(env_path)


def get_api_key() -> str:
    """Get OpenAI API key from environment."""
    api_key = os.getenv("OPENAI_API_KEY")
    if not api_key:
        print("Error: OPENAI_API_KEY environment variable not set")
        print("Please create a .env file with your API key:")
        print("  OPENAI_API_KEY=your-key-here")
        sys.exit(1)
    return api_key


def read_text_input(text: Optional[str], text_file: Optional[str],
                    pdf_file: Optional[str]) -> Tuple[str, str, str]:
    """
    Read text input from one of three sources.

    Args:
        text: Direct text input
        text_file: Path to text file
        pdf_file: Path to PDF file

    Returns:
        Tuple of (input_text, input_method, source_name)
    """
    if text:
        return text, "text", "demo"

    elif text_file:
        file_path = Path(text_file)
        if not file_path.exists():
            print(f"Error: File not found: {text_file}")
            sys.exit(1)

        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()

        return content, "text-file", f"file:{file_path.name}"

    elif pdf_file:
        file_path = Path(pdf_file)
        if not file_path.exists():
            print(f"Error: PDF file not found: {pdf_file}")
            sys.exit(1)

        try:
            reader = PdfReader(str(file_path))
            text_content = ""
            for page in reader.pages:
                text_content += page.extract_text()

            if not text_content.strip():
                print(f"Error: Could not extract text from PDF: {pdf_file}")
                sys.exit(1)

            return text_content, "pdf-file", f"pdf:{file_path.name}"
        except Exception as e:
            print(f"Error reading PDF: {e}")
            sys.exit(1)

    else:
        print("Error: Must provide one of --text, --text-file, or --pdf-file")
        sys.exit(1)


def get_embedding_from_openai(text: str, api_key: str) -> Dict[str, Any]:
    """
    Get embedding vector from OpenAI API.

    Args:
        text: Text to embed
        api_key: OpenAI API key

    Returns:
        API response dictionary
    """
    try:
        client = OpenAI(api_key=api_key)
        response = client.embeddings.create(
            model=MODEL,
            input=text
        )
        return response.model_dump()
    except Exception as e:
        print(f"Error calling OpenAI API: {e}")
        sys.exit(1)


def connect_db() -> psycopg2.extensions.connection:
    """
    Connect to PostgreSQL database.

    Returns:
        Database connection
    """
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        return conn
    except Exception as e:
        print(f"Error connecting to database: {e}")
        print(f"Connection details: {DB_CONFIG['host']}:{DB_CONFIG['port']}/{DB_CONFIG['database']}")
        sys.exit(1)


def format_embedding(embedding: List[float], full_array: bool = False) -> str:
    """
    Format embedding vector for display.

    Args:
        embedding: List of floats
        full_array: Whether to show all dimensions

    Returns:
        Formatted string
    """
    if full_array:
        return json.dumps(embedding, indent=2)
    else:
        preview = embedding[:10]
        return f"{preview} ... ({len(embedding)} total dimensions)"


def estimate_tokens(text: str) -> int:
    """
    Estimate the number of tokens in text.
    Uses rough approximation: 1 token ≈ 4 characters.

    Args:
        text: Input text

    Returns:
        Estimated token count
    """
    return len(text) // CHARS_PER_TOKEN


def chunk_text(text: str, chunk_size_tokens: int = CHUNK_SIZE) -> List[str]:
    """
    Split text into chunks that fit within token limits.
    Tries to split on paragraph boundaries, then sentences, then character limits.

    Args:
        text: Text to chunk
        chunk_size_tokens: Maximum tokens per chunk

    Returns:
        List of text chunks, each guaranteed to be <= chunk_size_tokens
    """
    estimated_tokens = estimate_tokens(text)

    # If text fits in one chunk, return as-is
    if estimated_tokens <= chunk_size_tokens:
        return [text]

    # Calculate chunk size in characters
    chunk_size_chars = chunk_size_tokens * CHARS_PER_TOKEN

    # Split into paragraphs (double newline)
    paragraphs = text.split('\n\n')

    chunks = []
    current_chunk = ""

    def add_to_chunk(piece: str) -> None:
        """Helper to add text piece to current chunk, splitting if needed."""
        nonlocal current_chunk

        # If piece itself is too large, do hard character split
        if len(piece) > chunk_size_chars:
            # Save current chunk if it exists
            if current_chunk:
                chunks.append(current_chunk.strip())
                current_chunk = ""

            # Split the large piece into character-based chunks
            for i in range(0, len(piece), chunk_size_chars):
                chunk_piece = piece[i:i + chunk_size_chars]
                chunks.append(chunk_piece.strip())
        # If adding piece would exceed limit, start new chunk
        elif len(current_chunk) + len(piece) + 2 > chunk_size_chars:
            if current_chunk:
                chunks.append(current_chunk.strip())
            current_chunk = piece
        # Otherwise add to current chunk
        else:
            current_chunk += ("\n\n" + piece if current_chunk else piece)

    for para in paragraphs:
        # If paragraph is too large, split by sentences
        if len(para) > chunk_size_chars:
            sentences = para.split('. ')
            for sentence in sentences:
                add_to_chunk(sentence if sentence.endswith('.') else sentence + '.')
        else:
            add_to_chunk(para)

    # Add remaining chunk
    if current_chunk:
        chunks.append(current_chunk.strip())

    return chunks


# Command: get-embeddings
def cmd_get_embeddings(args: argparse.Namespace) -> None:
    """Get embeddings command handler."""
    load_env()
    api_key = get_api_key()

    # Read input text
    input_text, input_method, _ = read_text_input(args.text, args.text_file, args.pdf_file)

    print("=== Getting Embedding from OpenAI ===\n")
    print(f"Input method: {input_method}")
    print(f"Text length: {len(input_text)} characters")
    print(f"Model: {MODEL}")
    print()

    # Preview text
    text_preview = input_text[:100] + ("..." if len(input_text) > 100 else "")
    print("Text preview:")
    print(text_preview)
    print()

    # Get embedding
    print("Sending request to OpenAI API...")
    response = get_embedding_from_openai(input_text, api_key)

    # Extract embedding
    embedding = response['data'][0]['embedding']
    total_tokens = response['usage']['total_tokens']

    print("✓ Embedding received successfully!\n")
    print(f"Embedding dimensions: {len(embedding)}")
    print(f"Tokens used: {total_tokens}")
    print()

    print("Embedding vector:")
    print(format_embedding(embedding, args.full_array))


# Command: store-embeddings
def cmd_store_embeddings(args: argparse.Namespace) -> None:
    """Store embeddings command handler with automatic chunking for large texts."""
    load_env()
    api_key = get_api_key()

    # Read input text
    input_text, input_method, source_name = read_text_input(
        args.text, args.text_file, args.pdf_file
    )

    # Override text with --text-key if provided
    base_text_label = input_text
    if args.text_key:
        if args.text:
            print("Warning: --text-key is ignored when using --text")
        else:
            base_text_label = args.text_key

    print("=== Storing Embedding in Database ===\n")
    print(f"Input method: {input_method}")
    print(f"Source: {source_name}")
    print(f"Text length: {len(input_text)} characters")
    print(f"Estimated tokens: {estimate_tokens(input_text)}")
    if args.text_key and not args.text:
        print(f"Text key: {base_text_label}")

    # Check if source already exists in database
    print("\nChecking for existing embeddings...")
    conn = connect_db()
    try:
        with conn.cursor() as cur:
            cur.execute(
                "SELECT COUNT(*) FROM text_embeddings WHERE source = %s",
                (source_name,)
            )
            existing_count = cur.fetchone()[0]

            if existing_count > 0:
                print(f"⚠️  Found {existing_count} existing record(s) with source: {source_name}")

                # Handle based on command-line flags
                if args.skip_if_exists:
                    print("Skipping (--skip-if-exists). No changes made.")
                    conn.close()
                    return
                elif args.replace_if_exists:
                    print(f"Replacing (--replace-if-exists). Deleting {existing_count} existing record(s)...")
                    cur.execute(
                        "DELETE FROM text_embeddings WHERE source = %s",
                        (source_name,)
                    )
                    conn.commit()
                    print(f"✓ Deleted {existing_count} record(s)\n")
                elif args.force:
                    print("Continuing with duplicate storage (--force)...\n")
                else:
                    # Interactive prompt
                    import sys
                    if not sys.stdin.isatty():
                        # Non-interactive mode (piped input, script, etc.)
                        print("Non-interactive mode detected. Use --skip-if-exists, --replace-if-exists, or --force")
                        conn.close()
                        return

                    print("\nOptions:")
                    print("  1. Skip - Don't store (keep existing)")
                    print("  2. Replace - Delete existing and store new")
                    print("  3. Continue - Store anyway (create duplicates)")
                    print()

                    try:
                        choice = input("Enter your choice (1/2/3): ").strip()
                    except EOFError:
                        print("\nNo input provided. Exiting.")
                        conn.close()
                        return

                    if choice == "1":
                        print("Skipping. No changes made.")
                        conn.close()
                        return
                    elif choice == "2":
                        print(f"Deleting {existing_count} existing record(s)...")
                        cur.execute(
                            "DELETE FROM text_embeddings WHERE source = %s",
                            (source_name,)
                        )
                        conn.commit()
                        print(f"✓ Deleted {existing_count} record(s)\n")
                    elif choice == "3":
                        print("Continuing with duplicate storage...\n")
                    else:
                        print("Invalid choice. Exiting.")
                        conn.close()
                        return
            else:
                print("✓ No existing records found for this source\n")
    finally:
        conn.close()

    # Check if text needs chunking
    estimated_tokens = estimate_tokens(input_text)
    if estimated_tokens > CHUNK_SIZE:
        print(f"\n⚠️  Text exceeds token limit ({estimated_tokens} tokens > {CHUNK_SIZE})")
        print("Splitting into chunks...")
        chunks = chunk_text(input_text, CHUNK_SIZE)
        print(f"Created {len(chunks)} chunks\n")
    else:
        chunks = [input_text]
        print()

    # Prepare base metadata
    metadata_base = {"type": input_method.replace("-", "_"), "input_method": input_method}
    if input_method == "text-file" and args.text_file:
        file_path = Path(args.text_file)
        metadata_base["filename"] = file_path.name
        metadata_base["size_bytes"] = file_path.stat().st_size
    elif input_method == "pdf-file" and args.pdf_file:
        file_path = Path(args.pdf_file)
        metadata_base["pdf_filename"] = file_path.name
        metadata_base["size_bytes"] = file_path.stat().st_size

    # Store each chunk
    conn = connect_db()
    try:
        for chunk_idx, chunk in enumerate(chunks, start=1):
            # Get embedding for this chunk
            if len(chunks) > 1:
                print(f"Processing chunk {chunk_idx}/{len(chunks)} ({len(chunk)} chars, ~{estimate_tokens(chunk)} tokens)...")
            else:
                print("Getting embedding from OpenAI...")

            response = get_embedding_from_openai(chunk, api_key)
            embedding = response['data'][0]['embedding']

            # Prepare chunk-specific metadata
            metadata = metadata_base.copy()
            if len(chunks) > 1:
                metadata["chunk_index"] = chunk_idx
                metadata["total_chunks"] = len(chunks)
                metadata["chunk_chars"] = len(chunk)

            # Determine text to store
            if args.text_key and not args.text:
                # Use custom key with chunk suffix if multiple chunks
                text_to_store = f"{base_text_label} (chunk {chunk_idx}/{len(chunks)})" if len(chunks) > 1 else base_text_label
            else:
                # Store the chunk content itself
                text_to_store = chunk

            # Insert into database
            with conn.cursor() as cur:
                cur.execute(
                    """
                    INSERT INTO text_embeddings (text, source, embedding, metadata)
                    VALUES (%s, %s, %s::vector, %s)
                    RETURNING id, text, source, metadata, created_at
                    """,
                    (text_to_store, source_name, json.dumps(embedding), Json(metadata))
                )
                result = cur.fetchone()
                conn.commit()

                if len(chunks) > 1:
                    print(f"  ✓ Chunk {chunk_idx} stored (ID: {result[0]})")
                else:
                    print("✓ Embedding stored successfully!\n")
                    print("Inserted record:")
                    print(f"  ID: {result[0]}")
                    print(f"  Text: {result[1][:100]}{'...' if len(result[1]) > 100 else ''}")
                    print(f"  Source: {result[2]}")
                    print(f"  Metadata: {result[3]}")
                    print(f"  Created: {result[4]}")

        if len(chunks) > 1:
            print(f"\n✓ All {len(chunks)} chunks stored successfully!")
            print(f"Total text length: {len(input_text)} characters")
            print(f"Source: {source_name}")

    finally:
        conn.close()


# Command: query-similar
def cmd_query_similar(args: argparse.Namespace) -> None:
    """Query similar texts command handler."""
    load_env()
    api_key = get_api_key()

    # Read input text
    input_text, input_method, _ = read_text_input(args.text, args.text_file, args.pdf_file)

    print("=== Querying Similar Texts ===\n")
    print(f"Input method: {input_method}")
    print(f"Query text length: {len(input_text)} characters")

    # Check if text exceeds token limit and truncate if needed
    estimated_tokens = estimate_tokens(input_text)
    print(f"Estimated tokens: {estimated_tokens}")

    if estimated_tokens > CHUNK_SIZE:
        print(f"\n⚠️  Query text exceeds token limit ({estimated_tokens} tokens > {CHUNK_SIZE})")
        print(f"Using first {CHUNK_SIZE} tokens (~{CHUNK_SIZE * CHARS_PER_TOKEN} characters) for query...")
        # Truncate to fit within token limit
        max_chars = CHUNK_SIZE * CHARS_PER_TOKEN
        input_text = input_text[:max_chars]
        print(f"Truncated to {len(input_text)} characters\n")

    print(f"Result limit: Top {RESULT_LIMIT} most similar")
    print()

    # Preview query text
    text_preview = input_text[:100] + ("..." if len(input_text) > 100 else "")
    print("Query text preview:")
    print(text_preview)
    print()

    # Get embedding for query
    print("Getting embedding from OpenAI...")
    response = get_embedding_from_openai(input_text, api_key)
    query_embedding = response['data'][0]['embedding']
    print("✓ Query embedding received\n")

    # Dump vector to file if requested
    if args.dump_vector:
        try:
            vector_data = {
                "model": MODEL,
                "dimensions": len(query_embedding),
                "embedding": query_embedding,
                "input_text_length": len(input_text),
                "input_text_preview": input_text[:100]
            }
            with open(args.dump_vector, 'w') as f:
                json.dump(vector_data, f, indent=2)
            print(f"✓ Vector saved to {args.dump_vector}\n")
        except Exception as e:
            print(f"Warning: Could not save vector to file: {e}\n")

    # Query database
    print("Searching database for similar texts...\n")
    conn = connect_db()
    try:
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT
                    id,
                    LEFT(text, 100) as text_preview,
                    source,
                    metadata,
                    1 - (embedding <=> %s::vector) as cosine_similarity,
                    embedding <=> %s::vector as cosine_distance,
                    created_at
                FROM text_embeddings
                ORDER BY embedding <=> %s::vector
                LIMIT %s
                """,
                (json.dumps(query_embedding),) * 3 + (RESULT_LIMIT,)
            )

            # Dump query to file if requested
            if args.dump_query:
                try:
                    # Prepare SQL template
                    query_template = """SELECT
    id,
    LEFT(text, 100) as text_preview,
    source,
    metadata,
    1 - (embedding <=> $1::vector) as cosine_similarity,
    embedding <=> $2::vector as cosine_distance,
    created_at
FROM text_embeddings
ORDER BY embedding <=> $3::vector
LIMIT $4"""

                    # Format vector as PostgreSQL array string
                    vector_str = json.dumps(query_embedding)
                    vector_preview = str(query_embedding[:10]) + " ..."

                    # Write file (overwrite mode 'w')
                    with open(args.dump_query, 'w') as f:
                        # Header
                        f.write("-- Query-Similar SQL Dump\n")
                        f.write(f"-- Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
                        f.write(f"-- Input method: {input_method}\n")
                        f.write(f"-- Vector dimensions: {len(query_embedding)}\n")
                        f.write(f"-- Result limit: {RESULT_LIMIT}\n\n")

                        # Section 1: Template with parameters
                        f.write("-- " + "=" * 60 + "\n")
                        f.write("-- SECTION 1: SQL Template (with parameter placeholders)\n")
                        f.write("-- " + "=" * 60 + "\n\n")
                        f.write(query_template + ";\n\n")
                        f.write("-- Parameters:\n")
                        f.write(f"-- $1, $2, $3: Query embedding vector ({len(query_embedding)} dimensions)\n")
                        f.write(f"-- First 10 dimensions: {vector_preview}\n")
                        f.write(f"-- $4: Result limit = {RESULT_LIMIT}\n\n")

                        # Section 2: Executable SQL
                        f.write("-- " + "=" * 60 + "\n")
                        f.write("-- SECTION 2: Executable SQL (ready to run in PostgreSQL)\n")
                        f.write("-- " + "=" * 60 + "\n\n")

                        # Replace placeholders with actual values
                        executable_query = query_template.replace("$1", f"'{vector_str}'")
                        executable_query = executable_query.replace("$2", f"'{vector_str}'")
                        executable_query = executable_query.replace("$3", f"'{vector_str}'")
                        executable_query = executable_query.replace("$4", str(RESULT_LIMIT))

                        f.write(executable_query + ";\n\n")
                        f.write(f"-- Note: Full vector embedded above ({len(query_embedding)} dimensions)\n")

                    print(f"✓ Query saved to {args.dump_query}\n")
                except Exception as e:
                    print(f"Warning: Could not save query to file: {e}\n")

            results = cur.fetchall()

            if not results:
                print("No results found in database.")
                print("Add some embeddings first using: store-embeddings")
                return

            print(f"=== Search Results (Top {RESULT_LIMIT}) ===\n")
            print(f"{'ID':<5} {'Text Preview':<50} {'Source':<20} {'Similarity':<12} {'Distance':<12}")
            print("-" * 110)

            for row in results:
                id_, text_preview, source, metadata, similarity, distance, created_at = row
                # Truncate text preview if too long
                text_preview = (text_preview[:47] + "...") if len(text_preview) > 50 else text_preview
                source = (source[:17] + "...") if len(source) > 20 else source

                print(f"{id_:<5} {text_preview:<50} {source:<20} {similarity:>11.4f} {distance:>11.4f}")

            print()
            print("Similarity score interpretation:")
            print("  1.0 = Identical")
            print("  0.9-0.99 = Very similar")
            print("  0.8-0.89 = Similar")
            print("  0.7-0.79 = Somewhat similar")
            print("  <0.7 = Less similar")
    finally:
        conn.close()


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description="AI Embedding Demo - Cross-platform Python CLI for OpenAI embeddings and pgvector",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Get embeddings
  python aiembedingdemo.py get-embeddings --text "Dog"
  python aiembedingdemo.py get-embeddings --text-file ../samples/dog.txt
  python aiembedingdemo.py get-embeddings --text "Dog" --full-array

  # Store embeddings
  python aiembedingdemo.py store-embeddings --text "Dog"
  python aiembedingdemo.py store-embeddings --text-file ../samples/cat.txt
  python aiembedingdemo.py store-embeddings --text-file ../samples/cat.txt --text-key "Feline"

  # Query similar
  python aiembedingdemo.py query-similar --text "Puppy"
  python aiembedingdemo.py query-similar --text-file ../samples/dog.txt
        """
    )

    subparsers = parser.add_subparsers(dest="command", help="Command to execute")
    subparsers.required = True

    # get-embeddings command
    parser_get = subparsers.add_parser(
        "get-embeddings",
        help="Get embeddings from OpenAI API"
    )
    input_group = parser_get.add_mutually_exclusive_group(required=True)
    input_group.add_argument("--text", type=str, help="Direct text input")
    input_group.add_argument("--text-file", type=str, help="Path to text file")
    input_group.add_argument("--pdf-file", type=str, help="Path to PDF file")
    parser_get.add_argument("--full-array", action="store_true",
                           help="Show all 1536 dimensions (default: first 10)")
    parser_get.set_defaults(func=cmd_get_embeddings)

    # store-embeddings command
    parser_store = subparsers.add_parser(
        "store-embeddings",
        help="Get embeddings and store in PostgreSQL database"
    )
    input_group = parser_store.add_mutually_exclusive_group(required=True)
    input_group.add_argument("--text", type=str, help="Direct text input")
    input_group.add_argument("--text-file", type=str, help="Path to text file")
    input_group.add_argument("--pdf-file", type=str, help="Path to PDF file")
    parser_store.add_argument("--text-key", type=str,
                             help="Custom text value for database (only with --text-file or --pdf-file)")
    duplicate_group = parser_store.add_mutually_exclusive_group()
    duplicate_group.add_argument("--skip-if-exists", action="store_true",
                                help="Skip if source already exists (no prompt)")
    duplicate_group.add_argument("--replace-if-exists", action="store_true",
                                help="Delete existing and replace (no prompt)")
    duplicate_group.add_argument("--force", action="store_true",
                                help="Store anyway, allow duplicates (no prompt)")
    parser_store.set_defaults(func=cmd_store_embeddings)

    # query-similar command
    parser_query = subparsers.add_parser(
        "query-similar",
        help="Query database for similar texts"
    )
    input_group = parser_query.add_mutually_exclusive_group(required=True)
    input_group.add_argument("--text", type=str, help="Direct text input")
    input_group.add_argument("--text-file", type=str, help="Path to text file")
    input_group.add_argument("--pdf-file", type=str, help="Path to PDF file")
    parser_query.add_argument("--dump-vector", type=str, metavar="FILE",
                             help="Save query embedding vector to JSON file")
    parser_query.add_argument("--dump-query", type=str, metavar="FILE",
                             help="Save SQL query to file")
    parser_query.set_defaults(func=cmd_query_similar)

    # Parse and execute
    args = parser.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
