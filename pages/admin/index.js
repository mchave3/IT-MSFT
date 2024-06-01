import { useSession, signIn, signOut } from 'next-auth/client';
import { useRouter } from 'next/router';
import { useEffect } from 'react';

export default function Admin() {
  const [session, loading] = useSession();
  const router = useRouter();

  useEffect(() => {
    if (!loading && !session) {
      router.push('/api/auth/signin');
    }
  }, [loading, session, router]);

  if (loading) return <p>Loading...</p>;

  if (!session) {
    return (
      <div>
        <h1>Admin Login</h1>
        <button onClick={() => signIn()}>Sign in</button>
      </div>
    );
  }

  return (
    <div>
      <h1>Admin Panel</h1>
      <p>Welcome, {session.user.name}</p>
      <button onClick={() => signOut()}>Sign out</button>

      <form method="post" action="/api/create-post">
        <div>
          <label>Title:</label>
          <input type="text" name="title" required />
        </div>
        <div>
          <label>Content:</label>
          <textarea name="content" required></textarea>
        </div>
        <button type="submit">Create Post</button>
      </form>
    </div>
  );
}
