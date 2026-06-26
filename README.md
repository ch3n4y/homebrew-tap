# Ch3n4y Tap

## How do I install these formulae?

`brew install ch3n4y/tap/<formula>`

Or `brew tap ch3n4y/tap` and then `brew install <formula>`.

Or, in a `brew bundle` `Brewfile`:

```ruby
tap "ch3n4y/tap"
brew "<formula>"
```

## EasyTier

Install:

```sh
brew install ch3n4y/tap/easytier
```

The Homebrew service supports two startup modes:

```sh
# 1. Run with the default local config file.
sudo brew services start easytier

# 2. Run with a web console config server.
sudo vi "$(brew --prefix)/etc/easytier/service.env"
# Set EASYTIER_CONFIG_SERVER, then restart:
sudo brew services restart easytier
```

Default local config:

```text
$(brew --prefix)/etc/easytier/default.conf
```

## Documentation

`brew help`, `man brew` or check [Homebrew's documentation](https://docs.brew.sh).
