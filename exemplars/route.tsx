import { createFileRoute } from '@tanstack/react-router';
import { z } from 'zod';
import { ResourceList } from '@/components/resources/resource-list';
import { ErrorState } from '@/components/ui/error-state';

const searchSchema = z.object({
  page: z.number().int().min(0).default(0),
  sortBy: z.enum(['name', 'updated']).default('name'),
});

export const Route = createFileRoute('/projects/$projectId/resources')({
  validateSearch: searchSchema,
  errorComponent: ({ error }) => <ErrorState error={error} />,
  component: ResourcesPage,
});

function ResourcesPage() {
  const { projectId } = Route.useParams();
  const { page, sortBy } = Route.useSearch();
  return <ResourceList projectId={projectId} page={page} sortBy={sortBy} />;
}
