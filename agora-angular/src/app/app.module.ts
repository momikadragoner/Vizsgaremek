import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { BrowserAnimationsModule } from "@angular/platform-browser/animations";

import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { FrontPageComponent } from './front-page/front-page.component';
import { FontAwesomeModule } from '@fortawesome/angular-fontawesome';
import { NavComponent } from './nav/nav.component';
import { LoginComponent } from './account-forms/login/login.component';
import { ProductListComponent } from './product-list/product-list.component';
import { ProductDetailComponent } from './product-detail/product-detail.component';
import { ModalComponent } from './modal/modal.component';
import { ReviewComponent } from './product-detail/review/review.component';
import { ProfilePageComponent } from './profile-page/profile-page.component';
import { FooterComponent } from './nav/footer/footer.component';
import { ReactiveFormsModule } from '@angular/forms';
import { AccountFormsComponent } from './account-forms/account-forms.component';
import { SignupCustomerComponent } from './account-forms/signup-customer/signup-customer.component';
import { SignupVendorComponent } from './account-forms/signup-vendor/signup-vendor.component';

@NgModule({
  declarations: [
    AppComponent,
    FrontPageComponent,
    NavComponent,
    LoginComponent,
    ProductListComponent,
    ProductDetailComponent,
    ModalComponent,
    ReviewComponent,
    ProfilePageComponent,
    FooterComponent,
    AccountFormsComponent,
    SignupCustomerComponent,
    SignupVendorComponent
  ],
  imports: [
    BrowserModule,
    FontAwesomeModule,
    AppRoutingModule,
    BrowserAnimationsModule,
    ReactiveFormsModule
  ],
  exports: [
    FontAwesomeModule
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule {}
