// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "deps/phoenix_html/web/static/js/phoenix_html"
import "jquery"
import "bootstrap-sass"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"

// Set up our Elm App
// We're using ports to provide the Elm app with
// the path to show contents (/contents/ and /admin/contents
// when in the admin area).
const ports = {
  contentBasePath: document.location.pathname + "/",
  adminArea: document.location.pathname.includes("admin/")
}
const elmDiv = document.querySelector('#elm-container');
const elmApp = Elm.embed(Elm.ContentIndex, elmDiv, ports);
