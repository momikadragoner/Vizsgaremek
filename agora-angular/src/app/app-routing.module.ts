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

const routes: Routes = [
  {path: '', component: FrontPageComponent},
  {path: 'login', component: LoginComponent},
  {path: 'product-details', component: ProductDetailComponent},
  {path: 'profile', component: ProfilePageComponent},
  {path: 'signup', component: SignupCustomerComponent},
  {path: 'signup-vendor', component: SignupVendorComponent},
  {path: 'messages', component: MessagesPageComponent},
  {path: 'add-product', component: ProductFormComponent},
  {path: 'my-profile', component: MyProfileComponent},
  {path: 'edit-profile', component: EditProfileComponent},
  {path: 'search', component: SearchComponent},
  {path: 'cart', component: CartComponent},
  {path: '**', component: FrontPageComponent}
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
