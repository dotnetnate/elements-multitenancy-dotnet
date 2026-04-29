# Web Frontend E2E Test Reference

> Comprehensive guide for browser-based end-to-end testing using **TypeScript** and **Playwright**. This applies regardless of backend language.

## Technology Stack

| Tool | Purpose |
|------|---------|
| **Playwright** | Browser automation framework — the ONLY supported tool |
| **TypeScript** | Test language — always TypeScript, never C# or Java |
| **@playwright/test** | Test runner with built-in assertions, fixtures, and configuration |

**Selenium, Cypress, and Puppeteer are NOT permitted.**

## Frontend Constraints

- **Angular** or **React** only — no other frameworks
- **No SSR (Server-Side Rendering)** — ever. Client-side rendering only.
- **No C# for frontend tests** — Playwright tests are always TypeScript

## Project Structure

```
src/Portals/admin-portal/front-end/
    e2e/
        fixtures/
            base.fixture.ts       # Custom fixture extending base.extend<T>()
            auth.fixture.ts       # Authentication fixture
        pages/
            projects.page.ts      # Page object for projects
            work-items.page.ts    # Page object for work items
        tests/
            projects.spec.ts      # Project management tests
            work-items.spec.ts    # Work item tests
        playwright.config.ts      # Playwright configuration
        global-setup.ts           # One-time setup (auth, seed data)
```

## Playwright Configuration

```typescript
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
    testDir: './tests',
    fullyParallel: true,
    forbidOnly: !!process.env.CI,
    retries: process.env.CI ? 2 : 0,
    workers: process.env.CI ? 1 : undefined,
    reporter: process.env.CI ? 'dot' : 'html',
    use: {
        trace: 'on-first-retry',
    },
    projects: [
        {
            name: 'chromium',
            use: { ...devices['Desktop Chrome'] },
        },
    ],
    webServer: {
        command: 'ng serve --configuration mock',
        url: 'http://localhost:4200',
        reuseExistingServer: !process.env.CI,
    },
});
```

Key settings:
- **`fullyParallel: true`** — tests run in parallel by default
- **Single browser project** — Chromium only unless cross-browser is explicitly required
- **`trace: 'on-first-retry'`** — captures trace on failure for debugging
- **`webServer`** — starts the Angular/React dev server automatically

## Custom Fixtures

Extend `base.extend<T>()` to provide reusable test context:

```typescript
import { test as base } from '@playwright/test';
import { ProjectsPage } from '../pages/projects.page';

type Fixtures = {
    projectsPage: ProjectsPage;
    authenticatedPage: Page;
};

export const test = base.extend<Fixtures>({
    projectsPage: async ({ page }, use) => {
        const projectsPage = new ProjectsPage(page);
        await projectsPage.goto();
        await use(projectsPage);
    },
    authenticatedPage: async ({ page }, use) => {
        // Perform authentication
        await page.goto('/login');
        await page.getByTestId('username').fill('test-user');
        await page.getByTestId('password').fill('test-password');
        await page.getByTestId('login-button').click();
        await use(page);
    },
});

export { expect } from '@playwright/test';
```

## Page Objects

```typescript
import { Page, Locator } from '@playwright/test';

export class ProjectsPage {
    readonly page: Page;
    readonly createButton: Locator;
    readonly nameInput: Locator;
    readonly descriptionInput: Locator;
    readonly submitButton: Locator;
    readonly projectList: Locator;

    constructor(page: Page) {
        this.page = page;
        this.createButton = page.getByTestId('create-project-button');
        this.nameInput = page.getByTestId('project-name');
        this.descriptionInput = page.getByTestId('project-description');
        this.submitButton = page.getByTestId('submit');
        this.projectList = page.getByTestId('project-list');
    }

    async goto() {
        await this.page.goto('/projects');
    }

    async createProject(name: string, description?: string) {
        await this.createButton.click();
        await this.nameInput.fill(name);
        if (description) {
            await this.descriptionInput.fill(description);
        }
        await this.submitButton.click();
    }
}
```

## Test Structure

Use **plain English test names** — not Given/When/Then:

```typescript
import { test, expect } from '../fixtures/base.fixture';

test.describe('Project Management', () => {
    test('creates a new project and shows it in the list', async ({ projectsPage }) => {
        await projectsPage.createProject('E2E Test Project', 'Test description');

        await expect(projectsPage.projectList).toContainText('E2E Test Project');
    });

    test('shows validation error for empty project name', async ({ projectsPage }) => {
        await projectsPage.createButton.click();
        await projectsPage.submitButton.click();

        await expect(projectsPage.page.getByTestId('name-error')).toBeVisible();
    });

    test('navigates to project details when clicking a project', async ({ projectsPage, page }) => {
        await projectsPage.projectList.getByText('Existing Project').click();

        await expect(page).toHaveURL(/\/projects\/[a-f0-9-]+/);
    });
});
```

## Element Selection

**Always use `data-testid` attributes** — never CSS classes, DOM structure, or text content for selection:

```typescript
// ✅ Correct
page.getByTestId('create-project-button')
page.getByTestId('project-name')
page.getByTestId('project-list')

// ❌ Wrong — brittle selectors
page.locator('.btn-primary')
page.locator('#create-project')
page.locator('div > form > button:first-child')
page.getByText('Create Project')  // Only for assertions, not selection
```

The frontend application MUST add `data-testid` attributes to all interactive elements.

## Assertions

Use Playwright's built-in `expect` with auto-waiting:

```typescript
// Visibility
await expect(page.getByTestId('success-message')).toBeVisible();
await expect(page.getByTestId('error-message')).not.toBeVisible();

// Text content
await expect(page.getByTestId('project-name')).toHaveText('My Project');
await expect(page.getByTestId('project-list')).toContainText('Test');

// URL
await expect(page).toHaveURL('/projects');
await expect(page).toHaveURL(/\/projects\/[a-f0-9-]+/);

// Count
await expect(page.getByTestId('project-card')).toHaveCount(3);

// Attribute
await expect(page.getByTestId('submit')).toBeEnabled();
await expect(page.getByTestId('submit')).toBeDisabled();
```

## Test Data Isolation

Each test creates and cleans up its own data:

```typescript
test('deletes a project', async ({ page }) => {
    // Setup — create test data via API
    const project = await apiHelper.createProject('Delete Me');

    // Test
    await page.goto(`/projects/${project.id}`);
    await page.getByTestId('delete-button').click();
    await page.getByTestId('confirm-delete').click();

    await expect(page.getByTestId('project-list')).not.toContainText('Delete Me');

    // No explicit cleanup needed — project was deleted by the test
});
```

## What to Test

- Critical user journeys (create, read, update, delete flows)
- Form validation messages display correctly
- Navigation between pages
- Error states render user-friendly messages
- Loading states appear during async operations

## What NOT to Test

- API behavior (covered by API tests)
- Visual styling or layout (use visual regression tools separately)
- Browser-specific quirks (test on Chromium unless cross-browser is required)
- Business logic (covered by backend unit tests)
