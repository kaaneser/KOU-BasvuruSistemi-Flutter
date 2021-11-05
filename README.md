# KOÜ Başvuru Sistemi - Application System

This app made for a school project.

<div class="row">
  <img src="emlakcipresentation.png"/>
</div>

## What is the KOU Basvuru Sistemi? What can you do in it?

**KOU is the abbreviation of Kocaeli University. It's a University at Turkey, Kocaeli. The app is made for collecting the applications made by students in KOU.**

**You can:**
 - If you're a student at there, you can create a personal account for make a application.
 - You can upload the required files for certain application type (Transcript etc.)
 - You can track the application made by yourself.
 - If you're an admin (It can be a teacher, worker at the University etc.) You can filter and list the applications of all application types, track them and accept or reject the applications made by students.

## Platform Support

**Platforms supported:**
 - Works fine in Android and iOS (The all of the back-end tested in iOS applications, so It's running more optimal than Android.)

## What is B+ tree algorithm and why do you use that?

  The application stored into a tree called B+ tree. With that tree you can store the reference of the exact data's keys and If you want to search some spesific value of the data, you don't search the all of the indexed table keys (It's not a linear algorithm, It's logarithmic.) and that's faster then the common models. So we use because of that.
 
## The Database Platform

  - The application's database is in a DigitalOcean server.
  - The server served in a domain named "koubsserver.live:5984" (name.com)

## Packages used from pub.dev

 - Wilt for made a connection to the CouchDB database.
 - url_launcher for opening the websites in the app.
 - animations for animated containers and routing.
 - Firebase (Core,Storage and Auth) for Authentication and Storing the files&images.
 - http for http requests.
 - balancedtrees for making a B+ trees including models.
 - image_picker for pick images from gallery.
 - file_picker for pick files from local storage.
 - syncfusion_flutter_pdf for generating the user's petition form generations.
 - json_object_lite for making a post or convert the database models.
 - open_file for see the uploading files (It's a design choice)
 - path_provider to save or check the local storage paths.

---

### Contributors:

Contributor  | Role | GitHub Profile |
:-------------: | :-------------: | :-------------: |
Kaan Yıldırım Eser  | Developer | [kaaneser](https://www.github.com/kaaneser) |
Hasan Koç  |  Developer | [Extr4ordinary](https://www.github.com/Extr4ordinary) |
| Merve Doğan | Developer | [Mmervedgnn](https://www.github.com/Mmervedgnn) |
| Duygu Şarkucu | Developer | [duygusarkucu](https://www.github.com/duygusarkucu) |
