# Database design

Before a single line of code, the schema decides whether the application is solid or falls apart. The usual approach is to open an agent, type "generate a production ready schema", and ship whatever comes back. That is how you get missing relationships, wrong field types, and tables that should not exist.

A model can generate tables. It cannot decide what your product is. **A production-ready database is designed, not generated.**

## The order of steps

Do not reorder these. Each one produces the input to the next.

### 1. Idea and scope

One paragraph. What is it, who uses it, what does it do.

### 2. Mini-PRD

Not a thirty-page document. A short list of the features the product needs, in plain language. Example shape:

> Workspaces represent individual companies. Users can join multiple workspaces. Channels live inside a workspace and are public or private. Channel memberships determine access. Messages are posted by users inside channels.

Every sentence there is a table and a relationship. That is the point of writing it.

### 3. Extract the entities

Read the PRD and pull out the nouns. Each becomes a table. Include the ones the PRD implies rather than names: "users can join multiple workspaces" is not two tables, it is three, because a join table has to exist.

List them all before designing any of them.

### 4. Fields and conventions

Give each table its own attributes only. Relationships come later.

Conventions, applied without exception:

- **Table names: lowercase and plural.** `users`, not `User`. A table holds many rows.
- **snake_case everywhere.** `first_name`, `avatar_url`, `is_private`. camelCase belongs to JavaScript, not to SQL. Mixing the two is the most common inconsistency there is, and it makes joins harder to read.
- **`created_at` and `updated_at` on every table.** Every one, even when you are sure you will not need them.

That last rule earns its own paragraph. Say a bot spams your waitlist with five thousand fake signups. Without timestamps, you have a table of emails and no way to tell fake from real. With them, you see five thousand rows created inside a one-minute window and you delete exactly those. The same field gives you auditability, analytics, and debugging. And you cannot add it retroactively to data that already exists.

### 5. Primary keys

Every row must be uniquely and stably identifiable. A table with duplicate values and no key is a table where you cannot tell two rows apart, which means you cannot reliably update or delete either one.

A primary key must be:

- **unique**
- **never null**
- **stable**, never mutated
- **not business logic**

That last one rules out the tempting choices. An email is unique and non-null, so it looks like a fine key, but the user can change it in settings, which breaks stability. Worse, business requirements change: drop the email field in favor of a phone number six months from now and every key in the database is gone.

So: a dedicated `id` column on every table, carrying no meaning.

> **VERIFY:** the id type your database and ORM recommend today (uuid, cuid, ulid, or auto-increment), how to generate it at the database or ORM level, and the current index implications of each. Look this up for the specific ORM version being installed. Sortable string ids are common now for a reason, but the recommendation moves.

### 6. Relationships and the ERD

Draw it. A diagram makes a wrong relationship obvious in a way a schema file never does. Any ERD tool works.

**One to one.** One user has one preferences record. Foreign key on one side, **marked unique**. Without the unique constraint you have accidentally built a one-to-many.

**One to many.** The most common. One user creates many portfolios; each portfolio belongs to one user. The "many" side holds the foreign key pointing at the "one" side's primary key.

**Many to many.** Users belong to many channels; channels have many users. You cannot express this with two columns. It requires a **join table** (also called a junction or bridge table) holding a foreign key to each side.

The join table is not plumbing to hide. It is usually a real entity with real fields. `channel_memberships` carries the member's `role`. `watchlist_items` carries when the item was added. If a join table has attributes, that confirms it deserved to exist.

Foreign keys are not optional decoration. They are what keeps referential integrity from drifting.

### 7. Optimization pass

Go back over the finished diagram:

- **Enums** for fields with a fixed, known set of values: `role` as owner/admin/member, `status`, `visibility`. A string column here is an invitation to typos.
- **Indexes** on foreign keys and on any column you will filter or sort by regularly.
- **Nullability**, deliberately. Which fields are genuinely optional?
- **Uniqueness**, deliberately. Slugs, emails, and the FK on the one-to-one side.

> **VERIFY:** current schema syntax for the ORM, how it wants enums declared, how indexes and compound unique constraints are expressed, and the current migration workflow. Look this up before writing the schema file, not after the first error.

## Common mistakes

| Mistake | Consequence |
|---|---|
| Business logic as the primary key | Key becomes unstable or disappears when requirements change |
| No timestamps | No auditing, no bot cleanup, cannot be added retroactively |
| Mixed naming (camelCase and snake_case) | Confusing joins, constant friction |
| Singular table names | Inconsistent, reads wrong |
| Missing foreign keys | Referential integrity drifts silently |
| Directly connecting two many-sides | Impossible; needs a join table |
| One-to-one without a unique FK | Silently a one-to-many |
| Generating the schema from a prompt | Missing relationships, wrong types, phantom tables |
