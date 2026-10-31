# Corpse Flower Marketplace

This is a Rails web app we built as a team of four for our software engineering course at the University of Memphis in Fall 2025.

The idea is simple: people can buy corpse flowers, which are rare plants famous for their huge blooms and terrible smell. Once someone owns one, they can add it to a scavenger hunt. Other users can go find the flower, upload a photo to prove they visited, and see where they rank on a leaderboard.

We split the work by user stories. Each of us worked on our own branch, and nothing went into main until someone else on the team had reviewed the pull request.

<!-- To add a screenshot, save it as docs/screenshot.png and remove the comment marks around the next line -->
<!-- ![Screenshot of the app](docs/screenshot.png) -->

## What the app does

- Shoppers can browse, search, filter and sort flowers, add them to a cart, check out, see their past orders and leave reviews.
- Flower owners can register their flower for the scavenger hunt with its location, a photo and directions for finding it.
- Hunters can search the registered flowers, log a visit with a photo, and check the leaderboard.
- Admins get a dashboard where they can manage listings and stock, suspend users, moderate reviews and read messages sent through the contact form.

## Built with

Ruby 3.3, Rails 7.1, PostgreSQL, Devise for login, Active Storage for photo uploads, Bootstrap for styling, and Minitest for testing. The team's test suite reached 96% line coverage.

## My part

I built the scavenger hunt feature. That included:

- the registration pages where owners add, view, edit and remove their flowers. The forms check that the location details are valid, for example that latitude and longitude fall within real ranges.
- making sure only the person who registered a flower can edit or remove it.
- connecting each registration to the order it came from, so the hunt is tied to an actual purchase.
- a search page for finding flowers by nickname, location or owner.
- visit check-ins with photos, and the leaderboard that ranks people by how many flowers they've found.

I also reviewed and merged a number of my teammates' pull requests.

## The team

Saiqua Islam, Tanvir Ahmed Joy, Sajal Das Shovon and Rafy.

We started from a Rails starter app provided by the course.

## Running it locally

You'll need Ruby 3.3.6, Bundler, PostgreSQL and Node.js installed. Then run:

```bash
bundle install
rails db:migrate:reset
rails db:seed
rails server
```

Open http://localhost:3000 in your browser. To run the tests, use `rails test`.
