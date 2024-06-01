import Link from 'next/link';
import Layout from '../../components/Layout';

export default function Blog() {
  const posts = [
    { id: 1, title: 'First Post', content: 'This is my first post.' },
    // Ajoutez plus de posts ici
  ];

  return (
    <Layout>
      <h1>Blog</h1>
      <ul>
        {posts.map(post => (
          <li key={post.id}>
            <Link href={`/blog/${post.id}`}><a>{post.title}</a></Link>
          </li>
        ))}
      </ul>
    </Layout>
  );
}
