import { useEffect } from 'react';
import { useQuery } from '@connectrpc/connect-query';
import { listTopics } from '@/gen/topic-TopicService_connectquery';

const TOPIC_LIST_STALE_TIME_MS = 30_000;

export function useTopicList(clusterId: string) {
  const { data, isLoading, error } = useQuery(
    listTopics,
    { clusterId },
    { staleTime: TOPIC_LIST_STALE_TIME_MS },
  );

  useEffect(function syncDocumentTitle() {
    if (data?.topics.length) {
      document.title = `Topics (${data.topics.length})`;
    }
  }, [data?.topics.length]);

  return { topics: data?.topics ?? [], isLoading, error };
}
