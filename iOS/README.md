# FirstStep iOS

The SwiftUI app uses the FastAPI jobs service at `http://127.0.0.1:8000` by default. Start the backend before running the app.

1. Open `fresher-jobs-india/fresher-jobs-india.xcodeproj` in Xcode.
2. Select the shared `FirstStep` scheme and an iOS Simulator, then Run.

For a physical iPhone, set the `API_BASE_URL` build setting to the Mac's LAN address, for example `http://192.168.1.20:8000`, and start the backend with `uvicorn app.main:app --host 0.0.0.0 --port 8000`. Keep both devices on the same trusted network.

## Structure

- `fresher-jobs-india/Core/Networking`: enum-based endpoints, typed requests, and the reusable generic `APIService`.
- `fresher-jobs-india/Models`: job and API response models.
- `fresher-jobs-india/Features/Jobs`: jobs screen and its `JobsViewModel`.
- `fresher-jobs-india/Features/Jobs/Components`: reusable search, filter, card, status, and empty-state views.
- `fresher-jobs-india/Features/JobDetail`: source-link detail sheet.
- `fresher-jobs-india/Core/DesignSystem`: shared app colors.
