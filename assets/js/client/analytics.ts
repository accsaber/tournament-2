import Plausible from "plausible-tracker";

const plausible = Plausible({
  apiHost: location.origin,
});

plausible.enableAutoPageviews();

export default Plausible;
