import { type ChangeEvent, useId, useState } from "react";

import {
  filterSkills,
  skillHref,
  skillSearchMessages,
  type SkillSearchItem,
} from "../skill-search.ts";

export const client = "load";

interface SkillSearchProps {
  locale: string;
  skills: SkillSearchItem[];
}

export default function SkillSearch({ locale, skills }: SkillSearchProps) {
  const [query, setQuery] = useState("");
  const inputId = useId();
  const resultsId = useId();
  const messages = skillSearchMessages(locale);
  const matches = filterSkills(skills, query);
  const trimmedQuery = query.trim();
  const status =
    trimmedQuery.length === 0
      ? messages.all(skills.length)
      : messages.matches(matches.length, trimmedQuery);

  const handleQueryChange = (event: ChangeEvent<HTMLInputElement>) => {
    setQuery(event.currentTarget.value);
  };

  return (
    <section className="not-prose mt-6">
      <div className="mb-5">
        <label
          className="mb-2 block font-medium text-foreground text-sm"
          htmlFor={inputId}
        >
          {messages.label}
        </label>
        <input
          aria-controls={resultsId}
          autoComplete="off"
          className="min-h-12 w-full rounded-blume border border-border bg-background px-4 py-3 text-base text-foreground shadow-sm transition-colors placeholder:text-muted-foreground focus-visible:border-accent focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-accent/40 focus-visible:ring-offset-2 focus-visible:ring-offset-background pointer-fine:text-sm"
          id={inputId}
          onChange={handleQueryChange}
          placeholder={messages.placeholder}
          spellCheck={false}
          type="search"
          value={query}
        />
      </div>

      <p aria-live="polite" className="mb-4 text-muted-foreground text-sm">
        {status}
      </p>

      <div className="grid gap-4 sm:grid-cols-2" id={resultsId}>
        {matches.map((skill) => (
          <a
            className="block rounded-blume border border-border bg-background p-5 text-inherit no-underline! transition-colors hover:border-accent hover:no-underline! focus-visible:border-accent focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-accent/40 focus-visible:ring-offset-2 focus-visible:ring-offset-background"
            href={skillHref(locale, skill.name)}
            key={skill.name}
          >
            <p className="mt-0! mb-1.5! font-medium text-foreground">
              /{skill.name}
            </p>
            <p className="m-0! text-muted-foreground text-sm">
              {skill.description}
            </p>
          </a>
        ))}
      </div>

      {matches.length === 0 ? (
        <div className="rounded-blume border border-border bg-muted/30 px-5 py-8 text-center">
          <p className="m-0! font-medium text-foreground">
            {messages.emptyTitle}
          </p>
          <p className="mt-2! mb-0! text-muted-foreground text-sm">
            {messages.emptyDescription}
          </p>
        </div>
      ) : null}
    </section>
  );
}
