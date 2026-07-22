/* Alpine.js component registry (CSP build).
 *
 * The self-hosted @alpinejs/csp build cannot evaluate inline expressions
 * (that would need 'unsafe-eval' in the CSP), so every component used in a
 * post must be registered here via Alpine.data() BEFORE Alpine boots.
 * Markup then references things by name only:
 *
 *   <div x-data="counter">
 *     <button x-on:click="increment">+</button>
 *     <span x-text="count"></span>
 *   </div>
 *
 * Register components inside the alpine:init listener below, e.g.:
 *
 *   Alpine.data('counter', () => ({
 *     count: 0,
 *     increment() { this.count++ },
 *   }))
 */

document.addEventListener('alpine:init', () => {
  // Alpine.data('componentName', () => ({ ... }))
});
