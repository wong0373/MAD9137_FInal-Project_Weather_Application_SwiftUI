# Weather Application

A SwiftUI-based weather application that provides real-time weather information for multiple cities worldwide.

## Description

This weather application allows users to:
- View weather information for multiple cities
- Search and add new cities
- View detailed weather information including temperature, humidity, wind speed
- See hourly forecasts
- View city locations on a map
- Customize refresh intervals
- Toggle between Celsius and Fahrenheit

## Features

- Real-time weather updates
- City search with autocomplete
- Detailed weather information
- Interactive maps
- Customizable refresh intervals
- Temperature unit conversion
- Popular cities quick-add
- Persistent storage of user preferences
- Beautiful gradient UI

## API Key Management

The application uses the OpenWeatherMap API. To use this application:

1. Sign up for a free API key at [OpenWeatherMap](https://openweathermap.org/api)
2. Replace the `apiKey` constant in `WeatherService.swift`:
```swift
private let apiKey = "YOUR_API_KEY"