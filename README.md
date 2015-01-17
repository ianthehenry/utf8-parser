# Decoding UTF-8 with Parser Combinators: Official Strategy Guide

This is the code associated with a yet-to-be-published blog post.

# Haskell

I'm not very familiar with Haskell. I've been playing with it for a little while now, and I've written a couple trivial apps. But I still have so much to learn it's not even funny.

So don't treat the code in this repository like "the right way to do it." This is code written by a beginner. A year from now I'm sure I'll look back on it and cringe.

If you happen to know a bit about Haskell and would like to give me some pointers on things I could be doing better, please do!

# How did you set this up

Since I had a small amount of trouble getting up-and-running with Haskell, and since hopefully the people reading the blog post are not all Haskell wizards, I thought it would be useful to document how I set this all up.

# Installing Haskell

I installed Haskell from [ghcformacosx](http://ghcformacosx.github.io/), because Homebrew doesn't work so well and at the time the Haskell Platform was several versions behind. After doing all the right stuff, I did this to generate the project:

    $ mkdir utf8-parser
    $ cd !$
    $ cabal init --is-executable --non-interactive
    $ cabal sandbox init

This is how I start all my Haskell adventures, and it basically leaves me with a blank project skeleton.

# The Prelude

Haskell's a little goofy.

There's a "standard library" that comes with the language called [`base`](http://hackage.haskell.org/package/base). But only a small subset of the standard library, called the `Prelude`, is "in scope" by default. So you have to import lots of things explicitly. Rather than doing that, I'm opting to use [`base-prelude`](http://hackage.haskell.org/package/base-prelude), which allows me to just write `import BasePrelude`.

But in order to do that I have to *disable* the automatic importing of the `Prelude`, which I do with by setting the `NoImplicitPrelude` flag on GHC (in my `.cabal` file).

The bottom line is that I no longer need to remember that I must explicitly import `Data.Functor.(<$>)` but not `Data.Functor.fmap` and various other little fun things like that. Much more of the `base` is available, and I like it that way.

I have gotten in the habit of starting all my project with `base-prelude`, as it doesn't seem to hurt anything and it lets me do less annoying `import` typing.

# Dependencies

After `base-prelude`, the only other dependencies I needed for this were `attoparsec` and `bytestring`. Even though `bytestring` is a dependency of `attoparsec`, I still need to list it in the cabal file in order for cabal to make it available to my module.

Now I'm ready to rock:

    $ cabal install --jobs --only-dependencies

I didn't really type that, because it turns out when you're trying to learn Haskell you type that *so frequently* that I aliased it to just `c`. But that's beside the point.

Then I created `Main.hs`, cracked open a bottle of my favorite text editor, and got to work actually doing the thing that the blog post is about.
