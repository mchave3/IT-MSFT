import { useRouter } from 'next/router';
import Layout from '../../components/Layout';

export default function PostPage() {
  const router = useRouter();
  const { id } = router.query;

  const post = { id, title: 'First Post', content: 'This is my first post.' }; // Remplacez par une récupération réelle de données

  return (
    <Layout>
      <h1>{post.title}</h1>
      <p>{post.content}</p>
    </Layout>
  );
}
