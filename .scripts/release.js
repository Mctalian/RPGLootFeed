const semanticRelease = require("semantic-release");
const fs = require("fs");

(async () => {
  try {
    const result = await semanticRelease.default({
      branches: ["main"],
      plugins: [
        "@semantic-release/commit-analyzer",
        "@semantic-release/release-notes-generator",
        "@semantic-release/github",
      ],
      preset: "angular",
    });

    if (result) {
      console.log("Release created:", result);
      console.log(`Version: ${result.nextRelease.version}`);

      // Set the RELEASE_CREATED environment variable
      fs.appendFileSync(process.env.GITHUB_ENV, `RELEASE_CREATED=true\n`);
      process.exit(0); // Success with release
    } else {
      console.log("No release created.");

      // Set the RELEASE_CREATED environment variable
      fs.appendFileSync(process.env.GITHUB_ENV, `RELEASE_CREATED=false\n`);
      process.exit(0); // Success, but no release
    }
  } catch (err) {
    console.error("Release failed:", err);
    process.exit(1); // Failure
  }
})();
