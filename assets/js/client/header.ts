const headerElement = document.querySelector("header");
const scrollCanary = document.querySelector("#scroll_canary");
const tournamentHeader = document.querySelector(".tournament-header");

const observer = new IntersectionObserver(([item]) => {
  if (item.isIntersecting) tournamentHeader?.classList.remove("scrolled");
  else tournamentHeader?.classList.add("scrolled");
});

if (scrollCanary) observer.observe(scrollCanary);
