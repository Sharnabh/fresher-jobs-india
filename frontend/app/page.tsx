"use client";

import { FormEvent, useEffect, useState } from "react";

type Job = { id: string; company: string; title: string; city: string; role: string; job_type: string; source_url: string; posted_at: string | null };
type Result = { items: Job[]; total: number };
type SyncStatus = { configured_boards: number; active_jobs: number; syncing: boolean; last_run: { status: string; boards_synced?: number } | null };
const API = process.env.NEXT_PUBLIC_API_URL ?? "http://localhost:8000";
const PAGE_SIZE = 50;
const roles = ["Software Engineering", "Data", "Product", "Design", "Marketing", "Sales", "Finance", "Operations", "Customer Support", "Other"];

export default function Home() {
  const [query, setQuery] = useState("");
  const [city, setCity] = useState("");
  const [role, setRole] = useState("");
  const [page, setPage] = useState(1);
  const [result, setResult] = useState<Result>({ items: [], total: 0 });
  const [loading, setLoading] = useState(true);
  const [apiOnline, setApiOnline] = useState(false);
  const [syncStatus, setSyncStatus] = useState<SyncStatus | null>(null);

  useEffect(() => {
    let cancelled = false;
    const refresh = () => {
      const params = new URLSearchParams();
      if (query.trim()) params.set("q", query.trim());
      if (city.trim()) params.set("city", city.trim());
      if (role) params.set("role", role);
      params.set("limit", String(PAGE_SIZE));
      params.set("offset", String((page - 1) * PAGE_SIZE));
      fetch(`${API}/jobs?${params.toString()}`)
        .then(async (response) => { if (!response.ok) throw new Error("API unavailable"); return response.json() as Promise<Result>; })
        .then((data) => { if (!cancelled) { setResult(data); setApiOnline(true); } })
        .catch(() => { if (!cancelled) setApiOnline(false); })
        .finally(() => { if (!cancelled) setLoading(false); });
      fetch(`${API}/sources/status`)
        .then(async (response) => { if (!response.ok) throw new Error("Status unavailable"); return response.json() as Promise<SyncStatus>; })
        .then((data) => { if (!cancelled) setSyncStatus(data); })
        .catch(() => { if (!cancelled) setSyncStatus(null); });
    };
    setLoading(true);
    refresh();
    const timer = window.setInterval(refresh, 30000);
    return () => { cancelled = true; window.clearInterval(timer); };
  }, [query, city, role, page]);

  useEffect(() => {
    const lastPage = Math.max(1, Math.ceil(result.total / PAGE_SIZE));
    if (page > lastPage) setPage(lastPage);
  }, [result.total, page]);

  function submit(event: FormEvent<HTMLFormElement>) { event.preventDefault(); }

  return (
    <main>
      <header className="topbar">
        <a className="brand" href="#top" aria-label="FirstStep home"><span className="brand-mark">F</span><span>firststep<span className="brand-dot">.</span></span></a>
        <nav aria-label="Main navigation"><a href="#search">Find a role</a><a href="#about">About</a></nav>
        <a className="source-link" href="#search">Explore roles <span aria-hidden="true">↗</span></a>
      </header>

      <section className="hero" id="top">
        <div className="hero-copy">
          <p className="eyebrow"><span className="live-dot" /> INDIA · EARLY CAREER</p>
          <h1>Your first role<br />starts <em>somewhere.</em></h1>
          <p className="intro">A clearer place to find internships and entry-level jobs from approved public sources.</p>
          <a className="button-primary" href="#search">Search open roles <span aria-hidden="true">↓</span></a>
          <p className="fine-print">Every listing links back to its original source.</p>
        </div>
        <div className="hero-note" aria-label="How the service works">
          <div className="note-top"><span className="note-label">THE SHORT VERSION</span><span className="note-index">01 / 03</span></div>
          <div className="note-flow"><span>Public listings</span><i>→</i><span>Clear filters</span><i>→</i><span>Your next step</span></div>
          <div className="note-rule" />
          <p>Less hunting across tabs. More time to find work that fits.</p>
          <span className="note-stamp">BUILT FOR<br />BEGINNINGS</span>
        </div>
        <div className="hero-bottom"><span>Internships and fresher roles</span><span>01 — SEARCH</span><span>Built with source links</span></div>
      </section>

      <section className="search-section" id="search">
        <div className="section-heading"><div><p className="eyebrow">THE LISTINGS</p><h2>Make the search <em>yours.</em></h2></div><p className="section-aside">Search by title, company, city or choose a role category. Open a listing at its source to apply.</p></div>
        <form className="filters" onSubmit={submit}>
          <label className="search-field"><span>KEYWORDS</span><input value={query} onChange={(event) => { setQuery(event.target.value); setPage(1); }} placeholder="Role, company or keyword" /></label>
          <label className="search-field"><span>CITY</span><input value={city} onChange={(event) => { setCity(event.target.value); setPage(1); }} placeholder="Any city" /></label>
          <label className="search-field role-field"><span>ROLE</span><select value={role} onChange={(event) => { setRole(event.target.value); setPage(1); }}><option value="">All roles</option>{roles.map((item) => <option key={item} value={item}>{item}</option>)}</select></label>
          <button className="filter-button" type="submit" aria-label="Apply filters">↗</button>
        </form>
        <div className="results-head"><p>{loading ? "Checking listings…" : result.total === 0 ? "0 roles" : `Showing ${(page - 1) * PAGE_SIZE + 1}–${Math.min(page * PAGE_SIZE, result.total)} of ${result.total} roles`}</p><p className="source-status"><span className={apiOnline ? "status-dot online" : "status-dot"} />{!apiOnline ? "API offline" : syncStatus?.syncing ? `Checking ${syncStatus.configured_boards} company boards` : syncStatus?.last_run?.status === "complete" || syncStatus?.last_run?.status === "partial" ? `Checked ${syncStatus.last_run.boards_synced ?? 0} boards` : `Starting checks for ${syncStatus?.configured_boards ?? "company"} boards`}</p></div>
        {result.items.length > 0 ? <div className="job-list">{result.items.map((job) => <a className="job-row" href={job.source_url} target="_blank" rel="noreferrer" key={job.id}><div className="job-company">{job.company.slice(0, 1).toUpperCase()}</div><div className="job-main"><h3>{job.title}</h3><p>{job.company} <span>·</span> {job.city}</p></div><div className="job-tags"><span>{job.role}</span><span>{job.job_type}</span></div><span className="job-arrow" aria-hidden="true">↗</span></a>)}</div> : <div className="empty-state"><span className="empty-number">01</span><div><h3>{loading ? "Looking for open roles" : "The first roles are on their way."}</h3><p>{apiOnline ? syncStatus?.syncing ? "We’re reading full job descriptions and checking experience requirements. Results will appear as the first refresh finishes." : "No fresher or internship roles matched yet. Try another search or check back after the feeds refresh." : "Start the backend to check the configured company career feeds."}</p></div><span className="empty-mark" aria-hidden="true">✳</span></div>}
        {result.total > PAGE_SIZE && <nav className="pagination" aria-label="Job result pages">
          <button type="button" onClick={() => setPage((current) => Math.max(1, current - 1))} disabled={page === 1}>Previous</button>
          {Array.from({ length: Math.min(5, Math.ceil(result.total / PAGE_SIZE)) }, (_, index) => {
            const pageCount = Math.ceil(result.total / PAGE_SIZE);
            const firstPage = Math.max(1, Math.min(page - 2, pageCount - 4));
            const pageNumber = firstPage + index;
            return <button type="button" key={pageNumber} onClick={() => setPage(pageNumber)} aria-label={`Go to page ${pageNumber}`} aria-current={page === pageNumber ? "page" : undefined} className={page === pageNumber ? "current-page" : ""}>{pageNumber}</button>;
          })}
          <button type="button" onClick={() => setPage((current) => Math.min(Math.ceil(result.total / PAGE_SIZE), current + 1))} disabled={page >= Math.ceil(result.total / PAGE_SIZE)}>Next</button>
          <span>Page {page} of {Math.ceil(result.total / PAGE_SIZE)}</span>
        </nav>}
        <p className="disclosure">Listings stay connected to their original source. Always confirm details and application status with the employer.</p>
      </section>

      <footer id="about"><a className="brand footer-brand" href="#top"><span className="brand-mark">F</span><span>firststep<span className="brand-dot">.</span></span></a><p>Good work starts with a first step.</p><span>INDIA · EARLY CAREER</span></footer>
    </main>
  );
}
