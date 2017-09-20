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

### Postfix

The idea for Postfix is to run 2 listeners:

1. Port 25: For server2server traffic, this is how emails are delivered to the hosted domains. No authentication, optional STARTTLS, only allows delivery to the hosted domains.
1. Port 587: Email submission. Authentication via SASL, required TLS via STARTTLS.

### Courier

Courier is configured with 1 listener:

1. Port 993: IMAPS over explicit TLS (switch to STARTTLS or run both?)

## Status

* Postfix: delivery to virtual domain works & tested, aliases not tested.
* Courier: problems with TLS, no tests
* Monitoring: no startup script, no service monitor
* Mailbox management: no solution for adding users to the mail DB yet.

## TODO

* Add proper tests, the current test script is shite.
