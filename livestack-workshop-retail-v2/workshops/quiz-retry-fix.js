/* Keep LiveLabs' existing score and badge rendering usable after Try Again. */
(function () {
  "use strict";

  var updateScore = window.updateQuizScore;
  if (typeof updateScore !== "function" || updateScore.retailRetryFix) {
    return;
  }

  function updateScoreAfterRetry() {
    var tracker = document.getElementById("ll-quiz-score-tracker");
    if (tracker && !tracker.querySelector(".ll-quiz-badge-container")) {
      var content = document.getElementById("module-content") || document;
      var badge = content.querySelector(".ll-quiz-badge-container");

      // LiveLabs moves this panel after the final question on completion,
      // but updateQuizScore looks for it inside the tracker on every call.
      // Return the same panel; the framework will render and place it again.
      if (badge) {
        tracker.appendChild(badge);
      }
    }

    return updateScore.apply(this, arguments);
  }

  updateScoreAfterRetry.retailRetryFix = true;
  window.updateQuizScore = updateScoreAfterRetry;
}());
