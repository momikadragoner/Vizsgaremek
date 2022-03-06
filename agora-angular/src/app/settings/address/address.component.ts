import { Component, OnInit } from '@angular/core';
import {
  faEdit,
  faMapMarkerAlt,
  faTrash,
} from '@fortawesome/free-solid-svg-icons';
import { Address, AddressService } from 'src/app/services/address.service';

@Component({
  selector: 'app-address',
  templateUrl: './address.component.html',
  styleUrls: ['./address.component.scss'],
})
export class AddressComponent implements OnInit {
  faTrash = faTrash;
  faEdit = faEdit;
  faMapMarkerAlt = faMapMarkerAlt;

  alertOpen: boolean = false;
  addressOpen: boolean = false;
  addresses: Address[] = [new Address()];
  selectedAddress: Address = new Address();

  constructor(private addressService: AddressService) {
    addressService.getAddress().subscribe({
      next: (data) => {
        this.addresses = [...data];
      },
    });
  }

  openEditModal(id: number) {
    this.selectedAddress = this.addresses.filter((x) => x.addressId == id)[0];
    this.addressOpen = true;
  }

  openDeleteModal(id: number) {
    this.selectedAddress = this.addresses.filter((x) => x.addressId == id)[0];
    this.alertOpen = true;
  }

  deleteAddress($event: any) {
    $event.preventDefault();
    this.addressService.deleteAddress(this.selectedAddress.addressId).subscribe({
      next: () => {
        this.addresses.splice(this.addresses.indexOf(this.addresses.filter(x => x.addressId == this.selectedAddress.addressId)[0]),1);
        this.alertOpen = false;
      }
    });
  }

  newAddress($event: any) {
    $event.preventDefault();
    this.selectedAddress = new Address();
    this.addressOpen = true;
  }

  addressChange(address:Address){
    let id:number = this.addresses.indexOf(this.addresses.filter(x => x.addressId == address.addressId)[0]);
    if (id == -1) this.addresses.push(address);
    else this.addresses[id] = address;
  }

  ngOnInit(): void { }
}
