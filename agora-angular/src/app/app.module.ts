import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { BrowserAnimationsModule } from "@angular/platform-browser/animations";
import { HttpClientModule } from '@angular/common/http';
import { FormsModule } from '@angular/forms';
import { RouterModule } from '@angular/router';

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
import { TrimPipe } from './trim.pipe';
import { CollapsePanelComponent } from './collapse-panel/collapse-panel.component';
import { HorizontalScrollDirective } from './horizontal-scroll.directive';
import { TagIconPipe } from "./tag-icon.pipe";
import { ScrollBlockDirective } from './scroll-block.directive';
import { ReviewFormComponent } from './product-detail/review-form/review-form.component';
import { CartComponent } from './cart/cart.component';
import { AddToCartComponent } from './product-detail/add-to-cart/add-to-cart.component';
import { ProductService } from './services/product.service';
import { UserService } from './services/user.service';
import { RootComponent } from './account-forms/root/root.component';
import { ApiService } from './account-forms/services/api.service';
import { AuthService } from './account-forms/services/auth.service';
import { CartService } from './services/cart.service';
import { WishListService } from './services/wishlist.service';
import { ReviewService } from './services/review.service';
import { FollowService } from './services/follow.service';
import { OrderComponent } from './order/order.component';
import { AddressService } from './services/address.service';
import { CheckoutComponent } from './checkout/checkout.component';
import { OrderManagementComponent } from './order-management/order-management.component';
import { SettingsComponent } from './settings/settings.component';
import { ProfileSettingsComponent } from './settings/profile-settings/profile-settings.component';
import { AddressComponent } from './settings/address/address.component';


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
    CategoriesComponent,
    TrimPipe,
    CollapsePanelComponent,
    HorizontalScrollDirective,
    TagIconPipe,
    ScrollBlockDirective,
    ReviewFormComponent,
    CartComponent,
    AddToCartComponent,
    RootComponent,
    OrderComponent,
    CheckoutComponent,
    OrderManagementComponent,
    SettingsComponent,
    ProfileSettingsComponent,
    AddressComponent
  ],
  imports: [
    BrowserModule,
    HttpClientModule,
    FontAwesomeModule,
    AppRoutingModule,
    BrowserAnimationsModule,
    ReactiveFormsModule,
    FormsModule,
    RouterModule,
    
  ],
  exports: [
    FontAwesomeModule
  ],
  providers: [
    ProductService,
    UserService,
    ApiService,
    AuthService,
    CartService,
    WishListService,
    ReviewService,
    FollowService,
    AddressService
  ],
  bootstrap: [AppComponent]
})
export class AppModule {}
