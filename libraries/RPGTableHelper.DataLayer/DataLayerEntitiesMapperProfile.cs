using AutoMapper;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Entities;

namespace RPGTableHelper.DataLayer
{
    public class DataLayerEntitiesMapperProfile : Profile
    {
        public DataLayerEntitiesMapperProfile()
        {
            CreateMap<User.UserIdentifier, Guid>().ConvertUsing((tmid, _) => tmid.Value);
            CreateMap<Guid, User.UserIdentifier>()
                .ConvertUsing((id, _) => User.UserIdentifier.From(id));

            CreateMap<User, UserEntity>().ReverseMap();
        }
    }
}
