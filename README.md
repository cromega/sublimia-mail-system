# The Subliminal Mail System

**Massive work in progress**

## What is it?

Really, it's just `postfix` and `courier-imap` packaged neatly in a container with `sqlite` as authentication/mailboxes backend.

It's supposed to be a deploy-and-run-and-do-your-thing kinda solution.

## How does it work?

The authentication flow looks like this:

```
postfix ----> cyrus-sasl ---
                            \
courier-imap --------------> courier-authlib (authdaemond) ---> sqlite
```

Also, Postfix uses the same DB for mailbox and alias lookup.

