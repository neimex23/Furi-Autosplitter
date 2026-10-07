# Publishing Furi Autosplitter and maintaining releases

[Español](PUBLISHING.md) | English

Prepared on 2026-10-07 for **1.0.0**, signed by **Neimex23**. This guide and the [XML snippet](livesplit-registration.xml) prepare registration; they do not mean the release has already been published or accepted by LiveSplit.

## 1. Publishing the release in your repository

1. Review changes, run compilation and regressions from [DEVELOPMENT.en.md](DEVELOPMENT.en.md), and keep the limitations from [CONTEXT.en.md](CONTEXT.en.md) in the release notes. Version 1.0.0 packages beta.8; it does not establish a complete run or a live test of final completion or Counter binding.
2. Generate the package with `powershell.exe -NoProfile -File .\tools\Empaquetar.ps1` from the repository root.
3. Commit reviewed source, tests and public documents and push them to `main` in [neimex23/Furi-Autosplitter](https://github.com/neimex23/Furi-Autosplitter). Keep `local/` and `dist/` out of Git.
4. On GitHub, open **Releases > Draft a new release**. Create tag `v1.0.0` at the published commit; suggested title: **Furi Autosplitter 1.0.0 — Neimex23**. Use the 1.0.0 changelog entry as release notes and attach `dist/Furi-Autosplitter-1.0.0.zip`. Publish the release.
5. While signed out, verify that the [direct ASL URL](https://raw.githubusercontent.com/neimex23/Furi-Autosplitter/main/ASL/Furi.asl) returns text beginning with `// Furi Autosplitter 1.0.0`. This file is what LiveSplit will download; the ZIP is for manual installation. The repository and file must be public.

## 2. Requesting availability when selecting Furi

LiveSplit describes registration through a pull request to its XML catalog, which its maintainers review and merge. [Official procedure](https://github.com/LiveSplit/LiveSplit.AutoSplitters#adding-an-auto-splitter).

1. Open [LiveSplit.AutoSplitters.xml](https://github.com/LiveSplit/LiveSplit.AutoSplitters/blob/master/LiveSplit.AutoSplitters.xml) and search for `Furi`. No exact entry was found in the 2026-10-07 lookup; check again before submitting. If one already exists, coordinate an update without duplicating the name.
2. Use GitHub's edit button and create the fork/branch when offered.
3. Insert the full contents of [livesplit-registration.xml](livesplit-registration.xml) inside the root `<AutoSplitters>` element, as a sibling of the other entries. Preserve the remaining XML. The URL points to `main/ASL/Furi.asl`, not the ZIP or the file's HTML page.
4. Open the pull request with title **Add Furi autosplitter**. Describe scope, the game's Game Time, options and tests. Disclose pending live checks; link the release and public context.
5. Wait for review and address feedback. Publishing your release does not itself add the game to the catalog. Acceptance and timing depend on LiveSplit.

After acceptance, restart LiveSplit with an Internet connection, open **Edit Splits**, enter **Furi** in **Game Name**, and press **Activate**. Open **Settings**, configure Start/Split and options, choose **Game Time**, and save the splits. Remove the manual Scriptable Auto Splitter from the layout if previously used, leaving only one instance. LiveSplit documents activation from the Splits Editor; its catalog is downloaded and it can fall back to a local copy if the network fails. [LiveSplit](https://github.com/LiveSplit/LiveSplit), [catalog reader](https://github.com/LiveSplit/LiveSplit/blob/master/src/LiveSplit.Core/Model/AutoSplitterFactory.cs).

## 3. Delivering updates

The proposal keeps a stable URL to the file on `main`. Therefore, another ASL is distributed by updating that same file; Furi does not need to be registered again while the name, path and metadata remain valid. This follows from the catalog storing a download URL without an ASL version number. [Official catalog](https://github.com/LiveSplit/LiveSplit.AutoSplitters/blob/master/LiveSplit.AutoSplitters.xml).

Recommended workflow for this project:

1. Develop and test on a branch. Once registered, the ASL on `main` will be the distribution source: do not push unverified experiments there.
2. Use **1.0.1** for fixes, **1.1.0** for compatible features and **2.0.0** for changes that break previous behavior/configuration. This is a project convention, not a catalog requirement.
3. Update the ASL header, visible version and messages, README, LEEME, REPORTAR-ERROR, AGENTS, context and changelogs in both languages. Preserve existing setting keys where possible.
4. Run compilation/regressions, document relevant live tests, and generate the new ZIP with `Empaquetar.ps1`.
5. Publish approved changes to `main` and create a new tag/release, such as `v1.0.1`, with its ZIP. Do not silently replace a previous tag.
6. Catalog users obtain content served by the same URL through LiveSplit. To check an update outside a run, restart LiveSplit and verify the compatible version with Furi open; if it still shows the previous version, deactivate/reactivate the autosplitter and check connectivity/cache. Instant updates of an already running instance are not promised.
7. Users loading a local copy through **Script Path** must download and replace that copy manually. A new ZIP or tag does not change their local file.

Another catalog PR is only needed when its entry changes, such as the URL, game names or description. If a bug is found, revert the problematic logic through a new commit and publish another patch version, keeping history intact.
