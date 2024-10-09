using AutoMapper;
using Prodot.Patterns.Cqrs.EfCore;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Entities;

namespace RPGTableHelper.DataLayer
{
    public class DataLayerEntitiesMapperProfile : Profile
    {
        public DataLayerEntitiesMapperProfile()
        {
            // User Mappings
            CreateModelMaps<User, User.UserIdentifier, Guid, UserEntity>();

            // EncryptionChallenge Mappings
            CreateMapBetweenIdentifiers<EncryptionChallenge.EncryptionChallengeIdentifier, Guid>();
            CreateMap<EncryptionChallenge, EncryptionChallengeEntity>()
                .ForMember(dest => dest.UserId, opt => opt.MapFrom(src => src.UserId.Value))
                .ReverseMap()
                .ForMember(
                    dest => dest.UserId,
                    opt => opt.MapFrom(src => new User.UserIdentifier { Value = src.UserId })
                );
        }

        private void CreateModelMaps<TModel, TIdentifier, TIdentifierValue, TEntity>()
            where TModel : ModelBase<TIdentifier, TIdentifierValue>, new()
            where TIdentifier : Identifier<TIdentifierValue, TIdentifier>, new()
        {
            CreateMapBetweenIdentifiers<TIdentifier, TIdentifierValue>();

            CreateMap<TModel, TEntity>().ReverseMap();
        }

        private void CreateMapBetweenIdentifiers<TIdentifier, TIdentifierValue>()
            where TIdentifier : Identifier<TIdentifierValue, TIdentifier>, new()
        {
            CreateMap<TIdentifier, TIdentifierValue>().ConvertUsing((tmid, _) => tmid.Value);
            CreateMap<TIdentifierValue, TIdentifier>()
                .ConvertUsing((id, _) => Identifier<TIdentifierValue, TIdentifier>.From(id));
        }
    }
}
