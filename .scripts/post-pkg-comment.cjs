module.exports = async ({
  github,
  context,
  noLibUrl,
  libsUrl,
  latestReleaseStandardSize,
  testPkgStandardSize,
  latestReleaseNoLibSize,
  testPkgNoLibSize,
}) => {
  const commentIdentifier = "### Packaged ZIP files"; // Unique phrase to identify the comment
  const linkStandard = `[RPGLootFeed ZIP (with libs)](${libsUrl})`;
  const linkNolib = `[RPGLootFeed ZIP (nolib)](${noLibUrl})`;

  const standardSizeDeltaPct =
    ((testPkgStandardSize - latestReleaseStandardSize) /
      latestReleaseStandardSize) *
    100;
  const standardSize = `(${latestReleaseStandardSize} ➡️ ${testPkgStandardSize}, ${standardSizeDeltaPct.toFixed(2)}%)`;
  const noLibSizeDeltaPct =
    ((testPkgNoLibSize - latestReleaseNoLibSize) / latestReleaseNoLibSize) *
    100;
  const noLibSize = `(${latestReleaseNoLibSize} ➡️ ${testPkgNoLibSize}, ${noLibSizeDeltaPct.toFixed(2)}%)`;
  let stdSizeWarning = "";
  if (standardSizeDeltaPct > 5) {
    stdSizeWarning = "⚠️";
  } else if (standardSizeDeltaPct < 0) {
    stdSizeWarning = "🟢";
  }

  let noLibSizeWarning = "";
  if (noLibSizeDeltaPct > 5) {
    noLibSizeWarning = "⚠️";
  } else if (noLibSizeDeltaPct < 0) {
    noLibSizeWarning = "🟢";
  }

  const lastUpdated = new Date().toLocaleString("en-US", {
    timeZone: "UTC",
    hour12: true,
  });
  const commentBody = `
${linkStandard} ${standardSize} ${stdSizeWarning}
${linkNolib} ${noLibSize} ${noLibSizeWarning}

Last Updated: ${lastUpdated} (UTC)
`;

  const { data: comments } = await github.rest.issues.listComments({
    issue_number: context.issue.number,
    owner: context.repo.owner,
    repo: context.repo.repo,
  });

  const existingComment = comments.find((comment) =>
    comment.body.includes(commentIdentifier),
  );

  if (existingComment) {
    // Update the existing comment
    await github.rest.issues.updateComment({
      comment_id: existingComment.id,
      owner: context.repo.owner,
      repo: context.repo.repo,
      body: `${commentIdentifier}\n${commentBody}`,
    });
  } else {
    // Create a new comment
    await github.rest.issues.createComment({
      issue_number: context.issue.number,
      owner: context.repo.owner,
      repo: context.repo.repo,
      body: `${commentIdentifier}\n${commentBody}`,
    });
  }
};
