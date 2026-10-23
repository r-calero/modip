# Third-party JavaScript (served as static files)

| File | Library | Version | License | Source |
|---|---|---|---|---|
| `3Dmol-2.0.4.min.js` | 3Dmol.js (molecular viewer) | 2.0.4 | BSD-3-Clause | https://cdnjs.cloudflare.com/ajax/libs/3Dmol/2.0.4/3Dmol-min.js |
| `Chart-2.9.4.min.js` | Chart.js (charts) | 2.9.4 | MIT | https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.9.4/Chart.min.js |

They are kept out of the asset pipeline because Uglifier 1.2 (Gemfile.lock)
cannot parse their modern JavaScript. Both files match the SHA-512 published
by cdnjs.
