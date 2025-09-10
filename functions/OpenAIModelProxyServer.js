import fetch from 'node-fetch';

export default async function ({ req, res, log, error }) {
  try {
    const OPENAI_API_KEY = process.env.OPENAI_API_KEY;
    if (!OPENAI_API_KEY) {
      return res.json({ error: 'Missing OpenAI API key in environment' }, 500);
    }

    // Parse JSON body
    const requestBody = JSON.parse(req.body || '{}');

    // Forward to OpenAI
    const openaiResponse = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${OPENAI_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(requestBody),
    });

    const openaiData = await openaiResponse.json();

    // Return OpenAI's response
    return res.json(openaiData);
  } catch (err) {
    req.log(err);
    return res.json({ error: 'Something went wrong', details: err.message }, 500);
  }
};