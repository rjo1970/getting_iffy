# Getting Iffy - A Ruby Kata

## About

You must refactor the beast that lies beneath the authorization mechanism of an invoice system.  You are new to the project.  All you see is a sea of "if" statements.  Your task:  Make the if statements go away.

The code is real.  It was at the bottom of our construction management invoice system that has handled billions of dollars of construction.  I have graciously been given permission by my supervisor to use it for this lesson.  Enjoy!

## Run

The kata was written with Ruby 1.9.3 and expects Minitest and SimpleCov.  Use 'bundle' to get everything just so.
A default rake task will run the tests and create a coverage report.  No fair changing the tests or modifying the stubbed-out classes and methods.

## The Lesson

Cyclomatic complexity kills.  It makes code hard to read, easy to leave untested, and provides places for nasty surprises that go bump in the dark of night.

## Spoiler

Partially influenced by https://twitter.com/KentBeck/status/239896132820541441

Try replacing the conditionals with a Hash that maps permission keys to boolean values.  Then, return the keys with true values.

## License

Under Apache 2.0 license.
