# Testing OpenAI Embeddings API

This document contains curl commands for testing the OpenAI embeddings API directly.

## Prerequisites

1. Set your OpenAI API key as an environment variable:
   ```bash
   source .env
   # or export OPENAI_API_KEY="your-key-here"
   ```

2. Install `jq` for pretty JSON output:
   ```bash
   # macOS
   brew install jq

   # Linux
   apt-get install jq
   ```

## API Endpoint

- **URL**: `https://api.openai.com/v1/embeddings`
- **Model**: `text-embedding-3-small`
- **Output dimensions**: 1536

## Test Commands with Pretty JSON Output

### Example 1: Dog

```bash
curl -X POST "https://api.openai.com/v1/embeddings" \
     -H "Authorization: Bearer $OPENAI_API_KEY" \
     -H "Content-Type: application/json" \
     -d '{"model": "text-embedding-3-small", "input": "Dog"}' | jq
```

### Example 2: Cat

```bash
curl -X POST "https://api.openai.com/v1/embeddings" \
     -H "Authorization: Bearer $OPENAI_API_KEY" \
     -H "Content-Type: application/json" \
     -d '{"model": "text-embedding-3-small", "input": "Cat"}' | jq
```

### Example 3: Duckbill

```bash
curl -X POST "https://api.openai.com/v1/embeddings" \
     -H "Authorization: Bearer $OPENAI_API_KEY" \
     -H "Content-Type: application/json" \
     -d '{"model": "text-embedding-3-small", "input": "Duckbill"}' | jq
```

## Understanding the Response

The API returns JSON with the following structure:

```json
{
  "object": "list",
  "data": [
    {
      "object": "embedding",
      "index": 0,
      "embedding": [
        0.0234567,
        -0.0123456,
        0.0567890,
        ...
        // 1536 total dimensions
      ]
    }
  ],
  "model": "text-embedding-3-small",
  "usage": {
    "prompt_tokens": 1,
    "total_tokens": 1
  }
}
```

### Key Fields

- **data[0].embedding**: Array of 1536 floating-point numbers representing the vector embedding
- **usage.total_tokens**: Number of tokens used (affects API cost)

## Extracting Just the Embedding Vector

To extract only the embedding vector:

```bash
curl -s -X POST "https://api.openai.com/v1/embeddings" \
     -H "Authorization: Bearer $OPENAI_API_KEY" \
     -H "Content-Type: application/json" \
     -d '{"model": "text-embedding-3-small", "input": "Dog"}' | jq '.data[0].embedding'
```

## Viewing First N Dimensions

To see just the first 10 dimensions:

```bash
curl -s -X POST "https://api.openai.com/v1/embeddings" \
     -H "Authorization: Bearer $OPENAI_API_KEY" \
     -H "Content-Type: application/json" \
     -d '{"model": "text-embedding-3-small", "input": "Dog"}' | jq '.data[0].embedding[0:10]'
```

## Testing with Longer Text

```bash
curl -X POST "https://api.openai.com/v1/embeddings" \
     -H "Authorization: Bearer $OPENAI_API_KEY" \
     -H "Content-Type: application/json" \
     -d '{"model": "text-embedding-3-small", "input": "The quick brown fox jumps over the lazy dog. This sentence contains every letter of the alphabet."}' | jq
```

## Error Handling

If you get an authentication error:
```json
{
  "error": {
    "message": "Incorrect API key provided",
    "type": "invalid_request_error",
    "param": null,
    "code": "invalid_api_key"
  }
}
```

Make sure your `OPENAI_API_KEY` is set correctly in the `.env` file.

## Cost Information

- **text-embedding-3-small**: $0.00002 per 1K tokens
- Most single words = 1 token
- A sentence ≈ 10-20 tokens

For detailed pricing, visit: https://openai.com/pricing

## Using Shell Scripts Instead

Instead of using curl directly, use the provided shell scripts:

```bash
# Get and display embedding
./02_get_embeddings.sh --text "Dog"

# Get, store, and query
./02_get_embeddings.sh --text "Dog"
./03_store_embeddings.sh --text "Dog"
./04_query_similar.sh --text "Cat"
```

These scripts handle authentication, error checking, and database storage automatically.
