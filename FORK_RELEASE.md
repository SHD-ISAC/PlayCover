# Fork release and signing policy

The `develop` workflow builds an Apple Silicon ad-hoc signed app; it is not
Developer ID signed or notarized by Apple. The test distribution retains
Hardened Runtime but has `com.apple.security.cs.disable-library-validation`
for the **app process only**, to accommodate bundled Sparkle. This lowers
protection against arbitrary code library loading in this process.

Fork test distributions carry `PlayCoverForkDistribution=unnotarized` in
Info.plist and intentionally disable the upstream Sparkle update controller.
Install updates manually from the fork release page after checking provenance.

A push to `release/publish-fork-vX.Y.Z.N` at an already successful `develop`
commit triggers `fork-release.yml`. It selects the successful CI job for the
exact Git SHA, verifies the recorded source commit and SHA-256 of the uploaded
archive, and publishes it as an explicitly **unnotarized GitHub pre-release**
with matching SHA-256 and warnings. It does not re-sign code or bypass Apple
Gatekeeper, SIP, or AMFI.

To create a truly Apple-notarized Release, use a valid Developer ID signing
identity, consistently sign embedded frameworks/helpers for the same team,
retain normal Library Validation, and pass Apple's notarization check. The
existing signed-release workflow must fail closed if credentials are unavailable.

The source project is https://github.com/PlayCover/PlayCover .
