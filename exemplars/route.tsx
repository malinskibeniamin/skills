import { createFileRoute } from '@tanstack/react-router';
import { z } from 'zod';
import { TopicList } from '@/components/topics/topic-list';
import { ErrorState } from '@/components/ui/error-state';

const searchSchema = z.object({
  page: z.number().int().min(0).default(0),
  sortBy: z.enum(['name', 'size']).default('name'),
});

export const Route = createFileRoute('/clusters/$clusterId/topics')({
  validateSearch: searchSchema,
  errorComponent: ({ error }) => <ErrorState error={error} />,
  component: TopicsPage,
});

function TopicsPage() {
  const { clusterId } = Route.useParams();
  const { page, sortBy } = Route.useSearch();
  return <TopicList clusterId={clusterId} page={page} sortBy={sortBy} />;
}
