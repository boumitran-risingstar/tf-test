const { OAuth2Client } = require('google-auth-library');
const client = new OAuth2Client();

async function authMiddleware(req, res, next) {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).send('Unauthorized: No token provided');
  }

  const idToken = authHeader.split('Bearer ')[1];

  try {
    const ticket = await client.verifyIdToken({
      idToken,
      audience: process.env.USERS_API_URL, // The URL of this service
    });
    const payload = ticket.getPayload();
    req.user = payload;
    next();
  } catch (error) {
    console.error('Error verifying ID token:', error);
    return res.status(401).send('Unauthorized: Invalid token');
  }
}

module.exports = authMiddleware;
