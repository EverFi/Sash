Sash
============

Badging issuing/hosting service that follows the metadata format of the great 
Mozilla Open Badge Infrastructure. Allows developers to stand up
their own badging platform and integrate badge creation and issuing into their 
own products.

# The Parts

  In Sash everything is organized undernearth an Organization.

## Creating Badges

  Sash provides a simple CRUD interface for creating and managing new badges.

## Issuing Badges

  A User on your platform fufills criteria for earning badge. System makes a server 
  side call to Sash with user login or email to issue badge.  User is 
  automatically initialized in the system if they don't exist (unique by 
  username), issues them the badge.

## Displaying Badges

  Retrieve Badges for username. Includes API for displaying new, unseen 
  badges, marking badges as seen by the user


## Badging Analytics

TBD


## Status

Sash is currently under development. If you want to get involved contact us @ engineering@everfi.com!

## License
Sash is released under the MIT License
