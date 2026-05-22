import { getBearerToken, verifySessionToken } from '../../../../../src/session';
import { getUserById } from '../../../../../src/users';

export const runtime = 'nodejs';

export async function GET(request: Request) {
  try {
    const token = getBearerToken(request);

    if (!token) {
      return Response.json({ error: 'missing_token' }, { status: 401 });
    }

    const session = verifySessionToken(token);

    if (!session) {
      return Response.json({ error: 'invalid_token' }, { status: 401 });
    }

    const user = await getUserById(session.sub);

    if (!user) {
      return Response.json({ error: 'user_not_found' }, { status: 401 });
    }

    return Response.json({ user });
  } catch (error) {
    console.error(error);
    return Response.json({ error: 'session_check_failed' }, { status: 500 });
  }
}
