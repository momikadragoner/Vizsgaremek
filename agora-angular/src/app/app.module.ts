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
import { MessagesPageComponent } from './messages-page/messages-page.component';
import { MessagesComponent } from './messages-page/messages/messages.component';
import { MyProfileComponent } from './my-profile/my-profile.component';
import { ProductFormComponent } from './my-profile/product-form/product-form.component';
import { MyProductListComponent } from './my-profile/my-product-list/my-product-list.component';
import { EditProfileComponent } from './my-profile/edit-profile/edit-profile.component';
import { ProductCardComponent } from './product-list/product-card/product-card.component';
import { PricePipe } from './price.pipe';
import { SearchComponent } from './search/search.component';
import { CategoriesComponent } from './search/categories/categories.component';

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
    SignupVendorComponent,
    MessagesPageComponent,
    MessagesComponent,
    MyProfileComponent,
    ProductFormComponent,
    MyProductListComponent,
    EditProfileComponent,
    ProductCardComponent,
    PricePipe,
    SearchComponent,
    CategoriesComponent
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
