"use strict";
(() => {
 const form = document.getElementById("order-filter");
 const select = document.getElementById("order-side");
 const rows = Array.from(document.querySelectorAll("tbody tr[data-side]"));
 const labels = {ALL: "All open orders", BUY: "Buy orders", SELL: "Sell orders"};
 function render(requested) {
  const valid = Object.prototype.hasOwnProperty.call(labels, requested);
  const side = valid ? requested : "ALL";
  select.value = side;
  let count = 0, remaining = 0;
  rows.forEach(row => {
   const show = side === "ALL" || row.dataset.side === side;
   row.hidden = !show;
   if (show) {count++; remaining += Number(row.dataset.remaining);}
  });
  document.getElementById("order-count").textContent = String(count);
  document.getElementById("remaining-shares").textContent = String(remaining);
  document.getElementById("order-scope").textContent = labels[side];
  document.getElementById("orders-heading").textContent = labels[side];
  document.getElementById("view-status").textContent = (valid ? "" : "Unrecognized order side. Showing all open orders. ") + labels[side];
 }
 render(new URLSearchParams(location.search).get("order_side") || "ALL");
 form.addEventListener("submit", event => {
  event.preventDefault(); const url = new URL(location.href);
  url.searchParams.set("order_side", select.value);
  history.replaceState(null, "", url); render(select.value);
 });
 window.addEventListener("popstate", () => render(new URLSearchParams(location.search).get("order_side") || "ALL"));
})();
