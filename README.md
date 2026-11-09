# Gallery App

An iOS image gallery app that fetches photos from the Unsplash API, displays them in a grid, allows browsing details with swipe navigation, and saves favourites locally.

## Configuration

The Unsplash Access Key is not committed to the repository. It lives in a separate `Config.xcconfig` file that is listed in `.gitignore`.

### 1. Create the config file

Create `TestGalleryApp/Config/Config.xcconfig` with the following content:

UNSPLASH_API_KEY = your_access_key_here

Replace `your_access_key_here` with your Unsplash Access Key from [unsplash.com/developers](https://unsplash.com/developers). No quotes, no spaces around `=`.

### 2. Connect the config in Xcode

1. In Xcode, select the **project** in the Project Navigator.
2. Open the **Info** tab.
3. In the **Configurations** section, for both **Debug** and **Release**, select `Config.xcconfig` in the dropdown next to the app target.

Without this step, `$(UNSPLASH_API_KEY)` in `Info.plist` will not be replaced with the real value.

## Overview

The app has three main screens:

- **Gallery** — a grid of photos fetched from Unsplash. Loads 30 photos per page and fetches the next page when scrolling near the bottom. Each cell shows a thumbnail and a heart icon if the photo is saved.
- **Detail** — pushed onto the navigation stack when a photo is tapped. Supports horizontal swipe navigation between photos, a description below the image, and a heart button to toggle favourite state. Pagination loads more photos when swiping near the end.
- **Favourites** — a grid of saved photos. Long-press opens a context menu to remove a photo (with confirmation). Tapping a favourite opens the Detail screen in read-only mode.

Favourite state is synced across all screens via `NotificationCenter`, so changes are reflected immediately.

## Architecture

The project follows **MVVM** with clear separation of concerns:

- **Presentation** — ViewControllers, ViewModels, Cells.
- **Domain** — models (`Photo`, `PhotoUrls`, `FavoritePhoto`) and protocols (`ImagesFetchServiceProtocol`, `FavoritesRepositoryProtocol`).
- **Data** — `ImagesFetchService` (URLSession + async/await), `FavoritesRepository` (CoreData), `CoreDataManager`.

### Patterns

- **Repository** — `FavoritesRepository` hides CoreData behind a simple API: `save`, `remove`, `fetchAll`, `isFavorite`.
- **Observer** — `NotificationCenter` (`.favoritesDidChange`) keeps Gallery, Detail, and Favourites in sync.
- **Singleton** — `CoreDataManager`
- **SOLID** — protocols for services and repositories, single responsibility per type, dependency inversion via `init`.

### Image Loading

Images are loaded and cached with **Kingfisher** (memory + disk). Cells call `kf.cancelDownloadTask()` in `prepareForReuse` to avoid flickering during fast scrolling.

### Pagination

Gallery uses `UICollectionViewCompositionalLayout` and triggers `loadNextPage()` when the user is 5 cells away from the end. Detail reuses the same `GalleryViewModel` to load more photos when swiping near the end.

## Tests

`PhotoParsingTests` — verifies that a sample Unsplash JSON decodes correctly into `[Photo]`, including `alt_description` → `altDescription` mapping.

`FavoritesRepositoryTests` — covers `save`, `fetchAll`, `remove`, and `isFavorite` using an in-memory CoreData store.

## Screenshots

| Gallery | Detail |
|---------|--------|
| <img width="300" src="https://github.com/user-attachments/assets/190e25a6-00d4-4f37-a891-f71bf7bf2867" /> | <img width="300" src="https://github.com/user-attachments/assets/4d438ec0-dd01-46f6-ab32-c116bfca0cc7" /> |

| Favourites | Remove from Favourites |
|------------|------------------------|
| <img width="300" src="https://github.com/user-attachments/assets/901aac45-885e-4016-a3d9-8f53b04ef6f8" /> | <img width="300" src="https://github.com/user-attachments/assets/92917777-19ca-49e6-8f8c-26da75050f65" /> |

## My Contacts

Matsvei Kavalenka: 
- **GitHub:** [estilay](https://github.com/estilay)
- **Telegram:** [@estilay](https://t.me/estilay)
- **Email:** kavalenkamatsvei@gmail.com
