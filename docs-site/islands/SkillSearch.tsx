import { type ChangeEvent, useId, useState } from "react";

import { groupSkills } from "../skill-groups.ts";
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
  const groups = trimmedQuery
    ? [{ id: "matches", title: "", skills: matches }]
    : groupSkills(matches, locale);

  const handleQueryChange = (event: ChangeEvent<HTMLInputElement>) => {
    setQuery(event.currentTarget.value);
  };

  return (
    <section className="skill-directory not-prose">
      <div className="skill-directory-search">
        <label className="skill-search-label" htmlFor={inputId}>
          {messages.label}
        </label>
        <input
          aria-controls={resultsId}
          autoComplete="off"
          className="skill-search-input"
          id={inputId}
          onChange={handleQueryChange}
          placeholder={messages.placeholder}
          spellCheck={false}
          type="search"
          value={query}
        />
        <p aria-live="polite" className="skill-search-status">
          {status}
        </p>
      </div>

      <div id={resultsId}>
        {groups.map((group, index) => (
          <section
            aria-labelledby={
              group.title ? `${resultsId}-${group.id}` : undefined
            }
            className={group.title ? "skill-workflow" : ""}
            key={group.id}
          >
            {group.title ? (
              <div className="skill-workflow-heading">
                <span aria-hidden="true" className="skill-workflow-number">
                  {String(index + 1).padStart(2, "0")}
                </span>
                <h3 id={`${resultsId}-${group.id}`}>{group.title}</h3>
                <span className="skill-workflow-count">
                  {group.skills.length}
                </span>
              </div>
            ) : null}
            <div className="skill-card-grid">
              {group.skills.map((skill) => (
                <a
                  className="skill-card"
                  href={skillHref(locale, skill.name)}
                  key={skill.name}
                >
                  <span aria-hidden="true" className="skill-card-mark">
                    /
                  </span>
                  <span className="skill-card-title">/{skill.name}</span>
                  <span className="skill-card-description">
                    {skill.description}
                  </span>
                  <span aria-hidden="true" className="skill-card-arrow">
                    ↗
                  </span>
                </a>
              ))}
            </div>
          </section>
        ))}
      </div>

      {matches.length === 0 ? (
        <div className="skill-search-empty">
          <p>{messages.emptyTitle}</p>
          <p>{messages.emptyDescription}</p>
        </div>
      ) : null}
    </section>
  );
}
