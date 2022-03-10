# Splash

_An iOS app that coordinates carpool for you and your Facebook friends._

## Awards
[**3rd Place @ 2022 Hoboken Climate Hackathon**](https://devpost.com/software/splash-uaxpfv)

## Inspiration

Carpooling is an incredibly efficient way to reduce carbon emissions from vehicles. It has become increasingly relevant as the end of the pandemic approaches and many people have started commuting to work again. However, carpooling is difficult to coordinate. That's why I built Splash, an iOS app to help inhabitants of Hoboken organize carpools with their friends.

## What it does

Splash enables the user to create their own routes (i.e. home to work) and view them in a map. They can see the routes their Facebook friends have created and compare their own routes to their friends'. When the user selects a friend's route and one of their own, the app can tell the user how long of a detour carpooling with a friend will require. Most importantly, it will present the environmental benefit of carpooling with that friend for the specified route.

## How I built it

The app infrastructure was built using SwiftUI. I made extensive use of MapKit to implement the location autocomplete within route creation, the map views for the routes, and the details for comparing routes. Lastly, I used Firebase and Meta for Developers to access the user's Facebook profile for logging in and accessing their friends.

## What's next for Splash

One potential feature would be adding integration with Apple Maps so the user can directly start their carpooling route from Splash. Another feature would be adding integration with Facebook Messenger so the user can send a message to their Facebook friend about carpooling from within the Splash app; this message would include the details of the carpooling route the user is interested in.

## [Video Demo](https://www.youtube.com/watch?v=lZcYaUp4560)
