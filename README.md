# project-fyt-ios
An Individual Content Deployment Application

"It's better to own something and sell 20,000 than give away a part of it and sell a million." - Bill Burr (Roughly)

## Preface

This is the iOS version of a dual Native app aims to give content creators the power to self advertise, self-moderate, and independently monetize their content. The end goal is to have Native codebases on both mobile platforms along with a MacOS application that will configure, deploy, and manage analytics for the Content Creators use cases. The MacOS app will also allow users to universally deploy their content across all major platforms simultaneously, as well as to their Mobile Apps that have been compiled and deployed to their respective stores through a locally containerized Jenkins process.

## Tech Stack
This is a native Swift iOS application using Supabase as a backend service. Limited use of external libraries will be used. Google services will not be used.

## Setup
You will have to create a `Keys.plist` file in the codebase (it will be gitignore-d) and give it the appropriate keys and values found in for `Supabase, OneSignal, and RevenueCat` for your supabase implementation. 

## Note on the License

This is a GNU AGPL licensed software repository. You really, really should read up on the limitations of what you can do with this software due to this license. There's a reason Google doesn't allow their devs to use this kind of software. Read more about it here: `https://snyk.io/learn/agpl-license/`

## FAQ

1. Why aren't you doing a Hybrid App?
- Hybrid sucks. It's always sucked. Always will suck. Find me a company more than 5 years old that has a Hybrid mobile app as their core product that can actually keep their engineers and customers happy. You won't. You can't. Why? See the first sentence of this answer. In fairness to JetBrains, Kotlin Multiplatform seems to not suck, but is too young to commit to for this project.

2. What's your list of MVP features for the iOS App?
- Expressive Twitter Style Feed for Images/Gifs/Videos/Text
- Twitter/Reddit Hybrid Comment-Reply System
- JWT/Refresh Token Authentication layer
- Simple-but-beautiful Video Player Support
- Video Library with Creator and Audience Member customizable collections and filtering
- Single Image and Image Collection Posts for jpgs, pngs, and gifs (gifs may be limited to single image posts)
- Highly Customizable In-App Surveys 
- Customizable Donation Petition UI
- Integrations with `linktr.ee`
- Customizable Color Scheme/Branding***
- Optional Feature Flags for Subscribers/VIPs***
- Subscriptions and In App Purchases via [RevenueCat](https://www.revenuecat.com/)
- Content Creator filters on who can see what for Subscriber/VIP audience members***
- Push Notifications via [OneSignal](https://www.onesignal.com/)
- Deep Links
- Localization

*** This will largely be handled with Supabase and the MacOS Application.

3. What are your list of post MVP features?
- TBD

4. Will you ever accept contributors?
- In the future as the product grows and gets fleshed out, perhaps. But they will likely be developers I already have a strong relationship with.

5. Why aren't you using Firebase/AWS/Scaled BEAAS?
- Did you even bother to read the whole point of this project?
