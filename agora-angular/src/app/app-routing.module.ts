import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { FrontPageComponent } from './front-page/front-page.component';
import { LoginComponent } from './account-forms/login/login.component';
import { ProductDetailComponent } from './product-detail/product-detail.component';
import { ProfilePageComponent } from './profile-page/profile-page.component';
import { SignupCustomerComponent } from './account-forms/signup-customer/signup-customer.component';
import { SignupVendorComponent } from './account-forms/signup-vendor/signup-vendor.component';
import { MessagesPageComponent } from './messages-page/messages-page.component';
import { ProductFormComponent } from './my-profile/product-form/product-form.component';
import { MyProfileComponent } from './my-profile/my-profile.component';
import { EditProfileComponent } from './my-profile/edit-profile/edit-profile.component';
import { SearchComponent } from './search/search.component';
import { CartComponent } from './cart/cart.component';
import { AuthGuardService } from './account-forms/services/auth-guard.service';
import { OrderComponent } from './order/order.component';
import { CheckoutComponent } from './checkout/checkout.component';
import { OrderManagementComponent } from './order-management/order-management.component';
import { SettingsComponent } from './settings/settings.component';
import { ProfileSettingsComponent } from './settings/profile-settings/profile-settings.component';
import { AddressComponent } from './settings/address/address.component';
import { OrderTrackingComponent } from './order-tracking/order-tracking.component';
import { NotificationsComponent } from './notifications/notifications.component';
import { GuideComponent } from './guide/guide.component';
import { NowComponent } from './front-page/now/now.component';
import { BestComponent } from './front-page/best/best.component';

const routes: Routes = [
  { path: '', component: FrontPageComponent, canActivate: [AuthGuardService] },
  { path: 'login', component: LoginComponent },
  { path: 'product-details/:id', component: ProductDetailComponent },
  { path: 'profile/:id', component: ProfilePageComponent },
  { path: 'signup', component: SignupCustomerComponent },
  { path: 'signup-vendor', component: SignupVendorComponent },
  { path: 'messages', component: MessagesPageComponent },
  { path: 'add-product', component: ProductFormComponent },
  { path: 'my-profile', component: MyProfileComponent },
  { path: 'search', component: SearchComponent },
  { path: 'cart', component: CartComponent },
  { path: 'order', component: OrderComponent },
  { path: 'checkout', component: CheckoutComponent },
  { path: 'order-management', component: OrderManagementComponent },
  { path: 'order-tracking', component: OrderTrackingComponent },
  { path: 'notifications', component: NotificationsComponent },
  { path: 'settings', component: SettingsComponent },
  { path: 'settings/profile-settings', component: ProfileSettingsComponent },
  { path: 'settings/address', component: AddressComponent },
  { path: 'guide', component: GuideComponent },
  { path: 'now', component: NowComponent },
  { path: 'best', component: BestComponent },
  { path: '**', component: FrontPageComponent },
];

@NgModule({
  imports: [RouterModule.forRoot(routes, { scrollPositionRestoration: 'top' })],
  exports: [RouterModule],
})
export class AppRoutingModule {}
