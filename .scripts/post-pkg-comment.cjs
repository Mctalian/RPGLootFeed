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

  const standardSize = `(${latestReleaseStandardSize} -> ${testPkgStandardSize})`;
  const noLibSize = `(${latestReleaseNoLibSize} -> ${testPkgNoLibSize})`;

  const lastUpdated = new Date().toLocaleString("en-US", {
    timeZone: "UTC",
    hour12: true,
  });
  const commentBody = `${linkStandard} ${standardSize}\n${linkNolib} ${noLibSize}\n\nLast Updated: ${lastUpdated} (UTC)`;

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
