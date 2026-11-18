# Fresher Jobs India

An early-stage job and internship finder for entry-level roles in India. The project is split into a Next.js frontend and a FastAPI backend. AI tagging uses Gemini 3.5 Flash-Lite, a model Google currently lists with free-tier input and output tokens, subject to availability and project quotas. Check current terms and pricing before use; quotas and model access can change.

## Structure

- `frontend/` — Next.js App Router, TypeScript, responsive job search interface.
- `backend/` — FastAPI API, SQLite storage, daily public-feed importer, Gemini tagging adapter.

## Requirements

- Node.js 20.9+ and npm.
- Python 3.11+.
- A Gemini API key with access to the Generative Language API.

## Start the backend

```sh
cd backend
python3 -m venv .venv
source .venv/bin/activate  # Windows: .venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env
```

Edit `backend/.env` and replace `GEMINI_API_KEY` with a newly rotated key. The provided key was pasted into chat, so revoke it before use. The key name you provided, `event_beep_api_key`, and project `projects/146751462003` identify the Google Cloud resource; the actual key secret belongs only in this ignored local `.env` file. Restrict the key to the Gemini API in Google AI Studio. Never put it in frontend code or commit it.

Then start the API:

```sh
uvicorn app.main:app --reload --port 8000
```

The API is at `http://localhost:8000`; interactive docs are at `/docs`. The local SQLite database is created at `backend/data/jobs.db`. `/health` reports whether a key is configured without exposing it. At startup the backend begins an initial sync, then repeats every 24 hours while it is running. `POST /sync` starts a manual refresh, and `GET /sources/status` reports progress and the last run.

## Start the frontend

In a second terminal:

```sh
cd frontend
npm install
cp .env.example .env.local
npm run dev
```

Open `http://localhost:3000`. The UI reports that it is waiting for approved feeds until the backend has real listings.

## Model and cost

The default model is `gemini-3.5-flash-lite`. It is suitable for high-volume extraction/tagging and is currently listed with free-tier token usage by Google. Free access has request limits, and Google's current free-tier terms say submitted content may be used to improve its products. If the project exceeds free quotas, Gemini may reject requests; check the current [pricing and free-tier limits](https://ai.google.dev/gemini-api/docs/pricing). The app does not automatically switch to a paid model.

## Job sources and fresher screening

`backend/sources.json` contains 292 company boards: 253 active India boards from the public Ashby, Greenhouse, and Lever directory, plus 39 curated India SmartRecruiters boards. Two stale boards that returned HTTP 404 (Libra AI and Arkose Labs) were removed. The original directory snapshot was updated 11 November 2026; the SmartRecruiters boards were selected from its India list and checked for live India postings on 17 November 2026. The company registries are reused under CC BY 4.0 with attribution to [deriverge's Ashby/Greenhouse/Lever directory](https://deriverge.com/tools/companies-using-ashby/) and its [SmartRecruiters directory](https://deriverge.com/tools/companies-using-smartrecruiters/). The importer calls documented public job-board endpoints, keeps employer application URLs, and does not store full descriptions. It caps new Gemini classifications at 500 per refresh by default; raise `GEMINI_MAX_CLASSIFICATIONS_PER_SYNC` carefully if a larger backlog remains. It reads complete descriptions temporarily for eligibility and Gemini tagging. Sources refresh in a background task at startup and every 24 hours while the backend is running.

The screening rule accepts internships and full-time entry-level roles when the job description indicates no more than two years of mandatory experience (or no experience is required). Higher experience that is explicitly preferred is not automatically disqualifying. Gemini receives the complete description, including requirement sections, and returns the experience requirement plus a short evidence excerpt. Low-confidence or unclear roles stay out of the public list. Use `GET /sources/status` to see source counts and errors. Company boards can change or close, so the current API response—not the directory's old open-job count—decides what is live.

The directory records public board URLs and is not a blanket grant to reuse each employer's content. The importer uses public ATS feeds, stores only listing metadata and the original application URL, and sends eligible candidates' descriptions to Gemini for classification. Verify any board's terms before public deployment; remove a source from `sources.json` if its terms do not permit this use. Feed docs: [Greenhouse](https://docs.greenhouse.io/job-board), [Lever](https://hire.lever.co/developer/documentation), [Ashby](https://developers.ashbyhq.com/docs/public-job-posting-api), [SmartRecruiters Posting API](https://developers.smartrecruiters.com/docs/endpoints).

### Direct company career pages

`backend/sources.json` also has a `direct_sites` list for company-hosted careers pages that publish Schema.org `JobPosting` JSON-LD. Add an entry only after manually reviewing the employer's terms for this use and checking its `robots.txt`; set `terms_reviewed` to `true` only after that review. Example shape:

```json
{
  "provider": "career_site",
  "company": "Example India Ltd",
  "url": "https://example.com/careers",
  "sitemaps": ["https://example.com/sitemap.xml"],
  "terms_reviewed": true
}
```

This adapter reads only robots-allowed pages on the same host, follows same-host sitemap locations (up to 50 pages per source), and extracts published `JobPosting` JSON-LD. It does not render JavaScript, inspect private/internal APIs, or defeat access controls. Sites that render jobs only through scripts or block crawling need a documented feed or employer permission; they are not collected by this adapter. The list is empty until a source passes that review and exposes structured postings.
