/**
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

/**
 * One Page Checkout — theme entry point
 *
 * The core (opc-form.js, opc-carrier-list.js, opc-carrier-select.js) owns
 * the full OPC lifecycle:
 *   - Form validation and pay button gating
 *   - Billing section toggle
 *   - Carrier list fetch, loader and error states
 *   - Cart summary and pay button amount update
 *
 * Add theme-specific behaviour here only — the core handles everything else.
 */

const initOnePageCheckout = (): void => {
  const {prestashop, Theme} = window;

  // Convert account-created success notification into a toast on OPC return.
  const toastTriggerEl = document.querySelector<HTMLElement>('#js-account-created-toast');
  const successAlert = document.querySelector<HTMLElement>('#notifications .alert-success');
  const toastMessage = toastTriggerEl?.dataset.message?.trim();
  const successMessage = successAlert?.textContent?.trim();

  if (toastMessage && successMessage && successMessage.includes(toastMessage)) {
    const toast = Theme?.components?.useToast?.(toastMessage, {type: 'success'});
    toast?.show?.();
    successAlert?.remove();
  }

  // Preserve Bootstrap accordion open state across cart summary DOM replacements.
  let openCollapseIds: string[] = [];

  prestashop.on('opcCartSummaryBeforeUpdate', ({selector}: {selector: string}) => {
    openCollapseIds = Array.from(document.querySelectorAll(`${selector} .accordion-collapse.show`))
      .map((el) => el.id)
      .filter(Boolean);
  });

  prestashop.on('opcCartSummaryUpdated', () => {
    openCollapseIds.forEach((id) => {
      const el = document.getElementById(id);

      if (!el) return;

      el.classList.add('show');

      const btn = document.querySelector(`[data-bs-target="#${id}"]`);

      if (btn) {
        btn.classList.remove('collapsed');
        btn.setAttribute('aria-expanded', 'true');
      }
    });
    openCollapseIds = [];
  });
};

export default initOnePageCheckout;
