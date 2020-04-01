# The Subliminal Mail System

**Massive work in progress**

## What is it?

Really, it's just `postfix` and `dovecot` packaged neatly in a container.

It's supposed to be a deploy-and-run-and-do-your-thing kinda solution.

## How does it work?

The authentication flow looks like this:

```
postfix
   |
   V
dovecot -> (flat file configs)
```

### Postfix

Postfix runs SMTP (optional STARTTLS) and Submission (required STARTTLS)

### Dovecot

Dovecot runs IMAP (required STARTTLS)
