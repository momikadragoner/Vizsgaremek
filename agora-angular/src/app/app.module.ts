import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { BrowserAnimationsModule } from "@angular/platform-browser/animations";

import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { FrontPageComponent } from './front-page/front-page.component';
import { FontAwesomeModule } from '@fortawesome/angular-fontawesome';
import { NavComponent } from './nav/nav.component';
import { LoginComponent } from './login/login.component';

@NgModule({
  declarations: [
    AppComponent,
    FrontPageComponent,
    NavComponent,
    LoginComponent
  ],
  imports: [
    BrowserModule,
    FontAwesomeModule,
    AppRoutingModule,
    BrowserAnimationsModule
  ],
  exports: [
    FontAwesomeModule
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule {}
