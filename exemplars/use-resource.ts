import { useEffect } from 'react';
import { useQuery } from '@connectrpc/connect-query';
import { listResources } from '@/gen/resource-ResourceService_connectquery';

const RESOURCE_LIST_STALE_TIME_MS = 30_000;

export function useResourceList(projectId: string) {
  const { data, isLoading, error } = useQuery(
    listResources,
    { projectId },
    { staleTime: RESOURCE_LIST_STALE_TIME_MS },
  );

  useEffect(function syncDocumentTitle() {
    if (data?.resources.length) {
      document.title = `Resources (${data.resources.length})`;
    }
  }, [data?.resources.length]);

  return { resources: data?.resources ?? [], isLoading, error };
}
