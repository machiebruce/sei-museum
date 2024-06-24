/** @format */

(function () {
  const idleDurationSecs = 10; // X number of seconds
  const redirectUrl = "qui.html"; // Redirect idle users to this URL
  let idleTimeout; // variable to hold the timeout, do not modify

  const resetIdleTimeout = function () {
    // Clears the existing timeout
    if (idleTimeout) clearTimeout(idleTimeout);

    idleTimeout = setTimeout(() => (location.href = redirectUrl), idleDurationSecs * 1000);
  };

  // Init on page load
  resetIdleTimeout();

  // Reset the idle timeout on any of the events listed below
  ["click", "touchstart", "mousemove"].forEach((evt) => document.addEventListener(evt, resetIdleTimeout, false));
})();
